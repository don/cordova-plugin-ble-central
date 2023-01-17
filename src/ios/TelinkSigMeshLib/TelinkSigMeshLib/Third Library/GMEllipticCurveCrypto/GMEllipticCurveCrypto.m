//
//  GMEllipticCurveCrypto.m
//
//  BSD 2-Clause License
//
//  Copyright (c) 2014 Richard Moore.
//
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//     list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
//  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//


#import "GMEllipticCurveCrypto.h"

/** Easy ecc - Relevant parts of ecc.c
 *
 *  The original easy-ecc code was left as untouched as possible:
 *    - The #define values were added as parameters with the same name as the #define
 *    - EccPoint was changed to be two uint64_t* with the suffixes, "x" and "y"
 *    - Optimized vli_mmod_fast functions have been prefixed with _BITS_ and a new dispatch function was added
 *    - Several casts to int were added to remove warnings (marked with /// Cast by RicMoo)
 *    - Switched from reading /dev/random to use "Randomiztion services".
 *
 *  The original code can be found at https://github.com/kmackay/easy-ecc
 *
 *  It was released under the BSD 2-Clause License:
 
 *  Copyright (c) 2013, Kenneth MacKay
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without modification,
 *  are permitted provided that the following conditions are met:
 *  * Redistributions of source code must retain the above copyright notice, this
 *  list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright notice,
 *  this list of conditions and the following disclaimer in the documentation
 *  and/or other materials provided with the distribution.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 *  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 *  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 *  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#define MAX_TRIES 16

typedef struct
{
    uint64_t m_low;
    uint64_t m_high;
} uint128_t;


static int getRandomNumber(uint64_t *p_vli, int NUM_ECC_DIGITS)
{
    int success = SecRandomCopyBytes(kSecRandomDefault, NUM_ECC_DIGITS * 8, (uint8_t*)p_vli);
    return (success == 0) ? 1: 0;
    
//    int l_fd = open("/dev/urandom", O_RDONLY | O_CLOEXEC);
//    if(l_fd == -1)
//    {
//        l_fd = open("/dev/random", O_RDONLY | O_CLOEXEC);
//        if(l_fd == -1)
//        {
//            return 0;
//        }
//    }
//    
//    char *l_ptr = (char *)p_vli;
//    size_t l_left = NUM_ECC_DIGITS * 8;
//    while(l_left > 0)
//    {
//        int l_read = read(l_fd, l_ptr, l_left);
//        if(l_read <= 0)
//        { // read failed
//            close(l_fd);
//            return 0;
//        }
//        l_left -= l_read;
//        l_ptr += l_read;
//    }
//    
//    close(l_fd);
//    return 1;
}

static void vli_clear(uint64_t *p_vli, int NUM_ECC_DIGITS)
{
    uint i;
    for(i=0; i<NUM_ECC_DIGITS; ++i)
    {
        p_vli[i] = 0;
    }
}

/* Returns 1 if p_vli == 0, 0 otherwise. */
static int vli_isZero(uint64_t *p_vli, int NUM_ECC_DIGITS)
{
    uint i;
    for(i = 0; i < NUM_ECC_DIGITS; ++i)
    {
        if(p_vli[i])
        {
            return 0;
        }
    }
    return 1;
}

/* Returns nonzero if bit p_bit of p_vli is set. */
static uint64_t vli_testBit(uint64_t *p_vli, uint p_bit)
{
    return (p_vli[p_bit/64] & ((uint64_t)1 << (p_bit % 64)));
}

/* Counts the number of 64-bit "digits" in p_vli. */
static uint vli_numDigits(uint64_t *p_vli, int NUM_ECC_DIGITS)
{
    int i;
    /* Search from the end until we find a non-zero digit.
     We do it in reverse because we expect that most digits will be nonzero. */
    for(i = NUM_ECC_DIGITS - 1; i >= 0 && p_vli[i] == 0; --i)
    {
    }
    
    return (i + 1);
}

/* Counts the number of bits required for p_vli. */
static uint vli_numBits(uint64_t *p_vli, int NUM_ECC_DIGITS)
{
    uint i;
    uint64_t l_digit;
    
    uint l_numDigits = vli_numDigits(p_vli, NUM_ECC_DIGITS);
    if(l_numDigits == 0)
    {
        return 0;
    }
    
    l_digit = p_vli[l_numDigits - 1];
    for(i=0; l_digit; ++i)
    {
        l_digit >>= 1;
    }
    
    return ((l_numDigits - 1) * 64 + i);
}

/* Sets p_dest = p_src. */
static void vli_set(uint64_t *p_dest, uint64_t *p_src, int NUM_ECC_DIGITS)
{
    uint i;
    for(i=0; i<NUM_ECC_DIGITS; ++i)
    {
        p_dest[i] = p_src[i];
    }
}

/* Returns sign of p_left - p_right. */
static int vli_cmp(uint64_t *p_left, uint64_t *p_right, int NUM_ECC_DIGITS)
{
    int i;
    for(i = NUM_ECC_DIGITS-1; i >= 0; --i)
    {
        if(p_left[i] > p_right[i])
        {
            return 1;
        }
        else if(p_left[i] < p_right[i])
        {
            return -1;
        }
    }
    return 0;
}

/* Computes p_result = p_in << c, returning carry. Can modify in place (if p_result == p_in). 0 < p_shift < 64. */
static uint64_t vli_lshift(uint64_t *p_result, uint64_t *p_in, uint p_shift, int NUM_ECC_DIGITS)
{
    uint64_t l_carry = 0;
    uint i;
    for(i = 0; i < NUM_ECC_DIGITS; ++i)
    {
        uint64_t l_temp = p_in[i];
        p_result[i] = (l_temp << p_shift) | l_carry;
        l_carry = l_temp >> (64 - p_shift);
    }
    
    return l_carry;
}

/* Computes p_vli = p_vli >> 1. */
static void vli_rshift1(uint64_t *p_vli, int NUM_ECC_DIGITS)
{
    uint64_t *l_end = p_vli;
    uint64_t l_carry = 0;
    
    p_vli += NUM_ECC_DIGITS;
    while(p_vli-- > l_end)
    {
        uint64_t l_temp = *p_vli;
        *p_vli = (l_temp >> 1) | l_carry;
        l_carry = l_temp << 63;
    }
}

/* Computes p_result = p_left + p_right, returning carry. Can modify in place. */
static uint64_t vli_add(uint64_t *p_result, uint64_t *p_left, uint64_t *p_right, int NUM_ECC_DIGITS)
{
    uint64_t l_carry = 0;
    uint i;
    for(i=0; i<NUM_ECC_DIGITS; ++i)
    {
        uint64_t l_sum = p_left[i] + p_right[i] + l_carry;
        if(l_sum != p_left[i])
        {
            l_carry = (l_sum < p_left[i]);
        }
        p_result[i] = l_sum;
    }
    return l_carry;
}

/* Computes p_result = p_left - p_right, returning borrow. Can modify in place. */
static uint64_t vli_sub(uint64_t *p_result, uint64_t *p_left, uint64_t *p_right, int NUM_ECC_DIGITS)
{
    uint64_t l_borrow = 0;
    uint i;
    for(i=0; i<NUM_ECC_DIGITS; ++i)
    {
        uint64_t l_diff = p_left[i] - p_right[i] - l_borrow;
        if(l_diff != p_left[i])
        {
            l_borrow = (l_diff > p_left[i]);
        }
        p_result[i] = l_diff;
    }
    return l_borrow;
}

static uint128_t mul_64_64(uint64_t p_left, uint64_t p_right)
{
    uint128_t l_result;
    
    uint64_t a0 = p_left & 0xffffffffull;
    uint64_t a1 = p_left >> 32;
    uint64_t b0 = p_right & 0xffffffffull;
    uint64_t b1 = p_right >> 32;
    
    uint64_t m0 = a0 * b0;
    uint64_t m1 = a0 * b1;
    uint64_t m2 = a1 * b0;
    uint64_t m3 = a1 * b1;
    
    m2 += (m0 >> 32);
    m2 += m1;
    if(m2 < m1)
    { // overflow
        m3 += 0x100000000ull;
    }
    
    l_result.m_low = (m0 & 0xffffffffull) | (m2 << 32);
    l_result.m_high = m3 + (m2 >> 32);
    
    return l_result;
}

static uint128_t add_128_128(uint128_t a, uint128_t b)
{
    uint128_t l_result;
    l_result.m_low = a.m_low + b.m_low;
    l_result.m_high = a.m_high + b.m_high + (l_result.m_low < a.m_low);
    return l_result;
}

static void vli_mult(uint64_t *p_result, uint64_t *p_left, uint64_t *p_right, int NUM_ECC_DIGITS)
{
    uint128_t r01 = {0, 0};
    uint64_t r2 = 0;
    
    uint i, k;
    
    /* Compute each digit of p_result in sequence, maintaining the carries. */
    for(k=0; k < NUM_ECC_DIGITS*2 - 1; ++k)
    {
        uint l_min = (k < NUM_ECC_DIGITS ? 0 : (k + 1) - NUM_ECC_DIGITS);
        for(i=l_min; i<=k && i<NUM_ECC_DIGITS; ++i)
        {
            uint128_t l_product = mul_64_64(p_left[i], p_right[k-i]);
            r01 = add_128_128(r01, l_product);
            r2 += (r01.m_high < l_product.m_high);
        }
        p_result[k] = r01.m_low;
        r01.m_low = r01.m_high;
        r01.m_high = r2;
        r2 = 0;
    }
    
    p_result[NUM_ECC_DIGITS*2 - 1] = r01.m_low;
}

static void vli_square(uint64_t *p_result, uint64_t *p_left, int NUM_ECC_DIGITS)
{
    uint128_t r01 = {0, 0};
    uint64_t r2 = 0;
    
    uint i, k;
    for(k=0; k < NUM_ECC_DIGITS*2 - 1; ++k)
    {
        uint l_min = (k < NUM_ECC_DIGITS ? 0 : (k + 1) - NUM_ECC_DIGITS);
        for(i=l_min; i<=k && i<=k-i; ++i)
        {
            uint128_t l_product = mul_64_64(p_left[i], p_left[k-i]);
            if(i < k-i)
            {
                r2 += l_product.m_high >> 63;
                l_product.m_high = (l_product.m_high << 1) | (l_product.m_low >> 63);
                l_product.m_low <<= 1;
            }
            r01 = add_128_128(r01, l_product);
            r2 += (r01.m_high < l_product.m_high);
        }
        p_result[k] = r01.m_low;
        r01.m_low = r01.m_high;
        r01.m_high = r2;
        r2 = 0;
    }
    
    p_result[NUM_ECC_DIGITS*2 - 1] = r01.m_low;
}


/* Computes p_result = (p_left + p_right) % p_mod.
 Assumes that p_left < p_mod and p_right < p_mod, p_result != p_mod. */
static void vli_modAdd(uint64_t *p_result, uint64_t *p_left, uint64_t *p_right, uint64_t *p_mod, int NUM_ECC_DIGITS)
{
    uint64_t l_carry = vli_add(p_result, p_left, p_right, NUM_ECC_DIGITS);
    if(l_carry || vli_cmp(p_result, p_mod, NUM_ECC_DIGITS) >= 0)
    { /* p_result > p_mod (p_result = p_mod + remainder), so subtract p_mod to get remainder. */
        vli_sub(p_result, p_result, p_mod, NUM_ECC_DIGITS);
    }
}

/* Computes p_result = (p_left - p_right) % p_mod.
 Assumes that p_left < p_mod and p_right < p_mod, p_result != p_mod. */
static void vli_modSub(uint64_t *p_result, uint64_t *p_left, uint64_t *p_right, uint64_t *p_mod, int NUM_ECC_DIGITS)
{
    uint64_t l_borrow = vli_sub(p_result, p_left, p_right, NUM_ECC_DIGITS);
    if(l_borrow)
    { /* In this case, p_result == -diff == (max int) - diff.
       Since -x % d == d - x, we can get the correct result from p_result + p_mod (with overflow). */
        vli_add(p_result, p_result, p_mod, NUM_ECC_DIGITS);
    }
}

/* Computes p_result = p_product % curve_p.
 See algorithm 5 and 6 from http://www.isys.uni-klu.ac.at/PDF/2001-0126-MT.pdf */
static void _128_vli_mmod_fast(uint64_t *p_result, uint64_t *p_product, int NUM_ECC_DIGITS, uint64_t *curve_p)
{
    uint64_t l_tmp[NUM_ECC_DIGITS];
    int l_carry;
    
    vli_set(p_result, p_product, NUM_ECC_DIGITS);
    
    l_tmp[0] = p_product[2];
    l_tmp[1] = (p_product[3] & 0x1FFFFFFFFull) | (p_product[2] << 33);
    l_carry = (int)vli_add(p_result, p_result, l_tmp, NUM_ECC_DIGITS);         /// Cast by RicMoo
    
    l_tmp[0] = (p_product[2] >> 31) | (p_product[3] << 33);
    l_tmp[1] = (p_product[3] >> 31) | ((p_product[2] & 0xFFFFFFFF80000000ull) << 2);
    l_carry += vli_add(p_result, p_result, l_tmp, NUM_ECC_DIGITS);
    
    l_tmp[0] = (p_product[2] >> 62) | (p_product[3] << 2);
    l_tmp[1] = (p_product[3] >> 62) | ((p_product[2] & 0xC000000000000000ull) >> 29) | (p_product[3] << 35);
    l_carry += vli_add(p_result, p_result, l_tmp, NUM_ECC_DIGITS);
    
    l_tmp[0] = (p_product[3] >> 29);
    l_tmp[1] = ((p_product[3] & 0xFFFFFFFFE0000000ull) << 4);
    l_carry += vli_add(p_result, p_result, l_tmp, NUM_ECC_DIGITS);
    
    l_tmp[0] = (p_product[3] >> 60);
    l_tmp[1] = (p_product[3] & 0xFFFFFFFE00000000ull);
    l_carry += vli_add(p_result, p_result, l_tmp, NUM_ECC_DIGITS);
    
    l_tmp[0] = 0;
    l_tmp[1] = ((p_product[3] & 0xF000000000000000ull) >> 27);
    l_carry += vli_add(p_result, p_result, l_tmp, NUM_ECC_DIGITS);
    
    while(l_carry || vli_cmp(curve_p, p_result, NUM_ECC_DIGITS) != 1)
    {
        l_carry -= vli_sub(p_result, p_result, curve_p, NUM_ECC_DIGITS);
    }
}

/* Computes p_result = p_product % curve_p.
 See algorithm 5 and 6 from http://www.isys.uni-klu.ac.at/PDF/2001-0126-MT.pdf */
static void _192_vli_mmod_fast(uint64_t *p_result, uint64_t *p_product, int NUM_ECC_DIGITS, uint64_t *curve_p)
{
    uint64_t l_tmp[NUM_ECC_DIGITS];
    int l_carry;
    
    vli_set(p_result, p_product, NUM_ECC_DIGITS);
    
    vli_set(l_tmp, &p_product[3], NUM_ECC_DIGITS);
    l_carry = (int)vli_add(p_result, p_result, l_tmp, NUM_ECC_DIGITS);          /// Cast by RicMoo
    
    l_tmp[0] = 0;
    l_tmp[1] = p_product[3];
    l_tmp[2] = p_product[4];
    l_carry += vli_add(p_result, p_result, l_tmp, NUM_ECC_DIGITS);
    
    l_tmp[0] = l_tmp[1] = p_product[5];
    l_tmp[2] = 0;
    l_carry += vli_add(p_result, p_result, l_tmp, NUM_ECC_DIGITS);
    
    while(l_carry || vli_cmp(curve_p, p_result, NUM_ECC_DIGITS) != 1)
    {
        l_carry -= vli_sub(p_result, p_result, curve_p, NUM_ECC_DIGITS);
    }
}

/* Computes p_result = p_product % curve_p
 from http://www.nsa.gov/ia/_files/nist-routines.pdf */
static void _256_vli_mmod_fast(uint64_t *p_result, uint64_t *p_product, int NUM_ECC_DIGITS, uint64_t *curve_p)
{
    uint64_t l_tmp[NUM_ECC_DIGITS];
    int l_carry;
    
    /* t */
    vli_set(p_result, p_product, NUM_ECC_DIGITS);
    
    /* s1 */
    l_tmp[0] = 0;
    l_tmp[1] = p_product[5] & 0xffffffff00000000ull;
    l_tmp[2] = p_product[6];
    l_tmp[3] = p_product[7];
    l_carry = (int)vli_lshift(l_tmp, l_tmp, 1, NUM_ECC_DIGITS);            /// Cast by RicMoo
    l_carry += vli_add(p_result, p_result, l_tmp, NUM_ECC_DIGITS);
    
    /* s2 */
    l_tmp[1] = p_product[6] << 32;
    l_tmp[2] = (p_product[6] >> 32) | (p_product[7] << 32);
    l_tmp[3] = p_product[7] >> 32;
    l_carry += vli_lshift(l_tmp, l_tmp, 1, NUM_ECC_DIGITS);
    l_carry += vli_add(p_result, p_result, l_tmp, NUM_ECC_DIGITS);
    
    /* s3 */
    l_tmp[0] = p_product[4];
    l_tmp[1] = p_product[5] & 0xffffffff;
    l_tmp[2] = 0;
    l_tmp[3] = p_product[7];
    l_carry += vli_add(p_result, p_result, l_tmp, NUM_ECC_DIGITS);
    
    /* s4 */
    l_tmp[0] = (p_product[4] >> 32) | (p_product[5] << 32);
    l_tmp[1] = (p_product[5] >> 32) | (p_product[6] & 0xffffffff00000000ull);
    l_tmp[2] = p_product[7];
    l_tmp[3] = (p_product[6] >> 32) | (p_product[4] << 32);
    l_carry += vli_add(p_result, p_result, l_tmp, NUM_ECC_DIGITS);
    
    /* d1 */
    l_tmp[0] = (p_product[5] >> 32) | (p_product[6] << 32);
    l_tmp[1] = (p_product[6] >> 32);
    l_tmp[2] = 0;
    l_tmp[3] = (p_product[4] & 0xffffffff) | (p_product[5] << 32);
    l_carry -= vli_sub(p_result, p_result, l_tmp, NUM_ECC_DIGITS);
    
    /* d2 */
    l_tmp[0] = p_product[6];
    l_tmp[1] = p_product[7];
    l_tmp[2] = 0;
    l_tmp[3] = (p_product[4] >> 32) | (p_product[5] & 0xffffffff00000000ull);
    l_carry -= vli_sub(p_result, p_result, l_tmp, NUM_ECC_DIGITS);
    
    /* d3 */
    l_tmp[0] = (p_product[6] >> 32) | (p_product[7] << 32);
    l_tmp[1] = (p_product[7] >> 32) | (p_product[4] << 32);
    l_tmp[2] = (p_product[4] >> 32) | (p_product[5] << 32);
    l_tmp[3] = (p_product[6] << 32);
    l_carry -= vli_sub(p_result, p_result, l_tmp, NUM_ECC_DIGITS);
    
    /* d4 */
    l_tmp[0] = p_product[7];
    l_tmp[1] = p_product[4] & 0xffffffff00000000ull;
    l_tmp[2] = p_product[5];
    l_tmp[3] = p_product[6] & 0xffffffff00000000ull;
    l_carry -= vli_sub(p_result, p_result, l_tmp, NUM_ECC_DIGITS);
    
    if(l_carry < 0)
    {
        do
        {
            l_carry += vli_add(p_result, p_result, curve_p, NUM_ECC_DIGITS);
        } while(l_carry < 0);
    }
    else
    {
        while(l_carry || vli_cmp(curve_p, p_result, NUM_ECC_DIGITS) != 1)
        {
            l_carry -= vli_sub(p_result, p_result, curve_p, NUM_ECC_DIGITS);
        }
    }
}

static void omega_mult(uint64_t *p_result, uint64_t *p_right, int NUM_ECC_DIGITS)
{
    uint64_t l_tmp[NUM_ECC_DIGITS];
    uint64_t l_carry, l_diff;
    
    /* Multiply by (2^128 + 2^96 - 2^32 + 1). */
    vli_set(p_result, p_right, NUM_ECC_DIGITS); /* 1 */
    l_carry = vli_lshift(l_tmp, p_right, 32, NUM_ECC_DIGITS);
    p_result[1 + NUM_ECC_DIGITS] = l_carry + vli_add(p_result + 1, p_result + 1, l_tmp, NUM_ECC_DIGITS); /* 2^96 + 1 */
    p_result[2 + NUM_ECC_DIGITS] = vli_add(p_result + 2, p_result + 2, p_right, NUM_ECC_DIGITS); /* 2^128 + 2^96 + 1 */
    l_carry += vli_sub(p_result, p_result, l_tmp, NUM_ECC_DIGITS); /* 2^128 + 2^96 - 2^32 + 1 */
    l_diff = p_result[NUM_ECC_DIGITS] - l_carry;
    if(l_diff > p_result[NUM_ECC_DIGITS])
    { /* Propagate borrow if necessary. */
        uint i;
        for(i = 1 + NUM_ECC_DIGITS; ; ++i)
        {
            --p_result[i];
            if(p_result[i] != (uint64_t)-1)
            {
                break;
            }
        }
    }
    p_result[NUM_ECC_DIGITS] = l_diff;
}

/* Computes p_result = p_product % curve_p
 see PDF "Comparing Elliptic Curve Cryptography and RSA on 8-bit CPUs"
 section "Curve-Specific Optimizations" */
static void _384_vli_mmod_fast(uint64_t *p_result, uint64_t *p_product, int NUM_ECC_DIGITS, uint64_t *curve_p)
{
    uint64_t l_tmp[2*NUM_ECC_DIGITS];
    
    while(!vli_isZero(p_product + NUM_ECC_DIGITS, NUM_ECC_DIGITS)) /* While c1 != 0 */
    {
        uint64_t l_carry = 0;
        uint i;
        
        vli_clear(l_tmp, NUM_ECC_DIGITS);
        vli_clear(l_tmp + NUM_ECC_DIGITS, NUM_ECC_DIGITS);
        omega_mult(l_tmp, p_product + NUM_ECC_DIGITS, NUM_ECC_DIGITS); /* tmp = w * c1 */
        vli_clear(p_product + NUM_ECC_DIGITS, NUM_ECC_DIGITS); /* p = c0 */
        
        /* (c1, c0) = c0 + w * c1 */
        for(i=0; i<NUM_ECC_DIGITS+3; ++i)
        {
            uint64_t l_sum = p_product[i] + l_tmp[i] + l_carry;
            if(l_sum != p_product[i])
            {
                l_carry = (l_sum < p_product[i]);
            }
            p_product[i] = l_sum;
        }
    }
    
    while(vli_cmp(p_product, curve_p, NUM_ECC_DIGITS) > 0)
    {
        vli_sub(p_product, p_product, curve_p, NUM_ECC_DIGITS);
    }
    vli_set(p_result, p_product, NUM_ECC_DIGITS);
}

static void vli_mmod_fast(uint64_t *p_result, uint64_t *p_product, int NUM_ECC_DIGITS, uint64_t *curve_p)
{
    switch (NUM_ECC_DIGITS) {
        case 2:
            _128_vli_mmod_fast(p_result, p_product, NUM_ECC_DIGITS, curve_p);
            break;
        case 3:
            _192_vli_mmod_fast(p_result, p_product, NUM_ECC_DIGITS, curve_p);
            break;
        case 4:
            _256_vli_mmod_fast(p_result, p_product, NUM_ECC_DIGITS, curve_p);
            break;
        case 6:
            _384_vli_mmod_fast(p_result, p_product, NUM_ECC_DIGITS, curve_p);
            break;
            
        default:
            NSLog(@"Curve undefined; no vli_mmod_fast defined");
            break;
    }

}

/* Computes p_result = (p_left * p_right) % curve_p. */
static void vli_modMult_fast(uint64_t *p_result, uint64_t *p_left, uint64_t *p_right, int NUM_ECC_DIGITS, uint64_t *curve_p)
{
    uint64_t l_product[2 * NUM_ECC_DIGITS];
    vli_mult(l_product, p_left, p_right, NUM_ECC_DIGITS);
    vli_mmod_fast(p_result, l_product, NUM_ECC_DIGITS, curve_p);
}

/* Computes p_result = p_left^2 % curve_p. */
static void vli_modSquare_fast(uint64_t *p_result, uint64_t *p_left, int NUM_ECC_DIGITS, uint64_t *curve_p)
{
    uint64_t l_product[2 * NUM_ECC_DIGITS];
    vli_square(l_product, p_left, NUM_ECC_DIGITS);
    vli_mmod_fast(p_result, l_product, NUM_ECC_DIGITS, curve_p);
}

#define EVEN(vli) (!(vli[0] & 1))
/* Computes p_result = (1 / p_input) % p_mod. All VLIs are the same size.
 See "From Euclid's GCD to Montgomery Multiplication to the Great Divide"
 https://labs.oracle.com/techrep/2001/smli_tr-2001-95.pdf */
static void vli_modInv(uint64_t *p_result, uint64_t *p_input, uint64_t *p_mod, int NUM_ECC_DIGITS)
{
    uint64_t a[NUM_ECC_DIGITS], b[NUM_ECC_DIGITS], u[NUM_ECC_DIGITS], v[NUM_ECC_DIGITS];
    uint64_t l_carry;
    int l_cmpResult;
    
    if(vli_isZero(p_input, NUM_ECC_DIGITS))
    {
        vli_clear(p_result, NUM_ECC_DIGITS);
        return;
    }
    
    vli_set(a, p_input, NUM_ECC_DIGITS);
    vli_set(b, p_mod, NUM_ECC_DIGITS);
    vli_clear(u, NUM_ECC_DIGITS);
    u[0] = 1;
    vli_clear(v, NUM_ECC_DIGITS);
    
    while((l_cmpResult = vli_cmp(a, b, NUM_ECC_DIGITS)) != 0)
    {
        l_carry = 0;
        if(EVEN(a))
        {
            vli_rshift1(a, NUM_ECC_DIGITS);
            if(!EVEN(u))
            {
                l_carry = vli_add(u, u, p_mod, NUM_ECC_DIGITS);
            }
            vli_rshift1(u, NUM_ECC_DIGITS);
            if(l_carry)
            {
                u[NUM_ECC_DIGITS-1] |= 0x8000000000000000ull;
            }
        }
        else if(EVEN(b))
        {
            vli_rshift1(b, NUM_ECC_DIGITS);
            if(!EVEN(v))
            {
                l_carry = vli_add(v, v, p_mod, NUM_ECC_DIGITS);
            }
            vli_rshift1(v, NUM_ECC_DIGITS);
            if(l_carry)
            {
                v[NUM_ECC_DIGITS-1] |= 0x8000000000000000ull;
            }
        }
        else if(l_cmpResult > 0)
        {
            vli_sub(a, a, b, NUM_ECC_DIGITS);
            vli_rshift1(a, NUM_ECC_DIGITS);
            if(vli_cmp(u, v, NUM_ECC_DIGITS) < 0)
            {
                vli_add(u, u, p_mod, NUM_ECC_DIGITS);
            }
            vli_sub(u, u, v, NUM_ECC_DIGITS);
            if(!EVEN(u))
            {
                l_carry = vli_add(u, u, p_mod, NUM_ECC_DIGITS);
            }
            vli_rshift1(u, NUM_ECC_DIGITS);
            if(l_carry)
            {
                u[NUM_ECC_DIGITS-1] |= 0x8000000000000000ull;
            }
        }
        else
        {
            vli_sub(b, b, a, NUM_ECC_DIGITS);
            vli_rshift1(b, NUM_ECC_DIGITS);
            if(vli_cmp(v, u, NUM_ECC_DIGITS) < 0)
            {
                vli_add(v, v, p_mod, NUM_ECC_DIGITS);
            }
            vli_sub(v, v, u, NUM_ECC_DIGITS);
            if(!EVEN(v))
            {
                l_carry = vli_add(v, v, p_mod, NUM_ECC_DIGITS);
            }
            vli_rshift1(v, NUM_ECC_DIGITS);
            if(l_carry)
            {
                v[NUM_ECC_DIGITS-1] |= 0x8000000000000000ull;
            }
        }
    }
    
    vli_set(p_result, u, NUM_ECC_DIGITS);
}

/* ------ Point operations ------ */

/* Returns 1 if p_point is the point at infinity, 0 otherwise. */
static int EccPoint_isZero(uint64_t *x, uint64_t *y, int NUM_ECC_DIGITS)
{
    return (vli_isZero(x, NUM_ECC_DIGITS) && vli_isZero(y, NUM_ECC_DIGITS));
}

/* Point multiplication algorithm using Montgomery's ladder with co-Z coordinates.
 From http://eprint.iacr.org/2011/338.pdf
 */

/* Double in place */
static void EccPoint_double_jacobian(uint64_t *X1, uint64_t *Y1, uint64_t *Z1, int NUM_ECC_DIGITS, uint64_t *curve_p)
{
    /* t1 = X, t2 = Y, t3 = Z */
    uint64_t t4[NUM_ECC_DIGITS];
    uint64_t t5[NUM_ECC_DIGITS];
    
    if(vli_isZero(Z1, NUM_ECC_DIGITS))
    {
        return;
    }
    
    vli_modSquare_fast(t4, Y1, NUM_ECC_DIGITS, curve_p);   /* t4 = y1^2 */
    vli_modMult_fast(t5, X1, t4, NUM_ECC_DIGITS, curve_p); /* t5 = x1*y1^2 = A */
    vli_modSquare_fast(t4, t4, NUM_ECC_DIGITS, curve_p);   /* t4 = y1^4 */
    vli_modMult_fast(Y1, Y1, Z1, NUM_ECC_DIGITS, curve_p); /* t2 = y1*z1 = z3 */
    vli_modSquare_fast(Z1, Z1, NUM_ECC_DIGITS, curve_p);   /* t3 = z1^2 */
    
    vli_modAdd(X1, X1, Z1, curve_p, NUM_ECC_DIGITS); /* t1 = x1 + z1^2 */
    vli_modAdd(Z1, Z1, Z1, curve_p, NUM_ECC_DIGITS); /* t3 = 2*z1^2 */
    vli_modSub(Z1, X1, Z1, curve_p, NUM_ECC_DIGITS); /* t3 = x1 - z1^2 */
    vli_modMult_fast(X1, X1, Z1, NUM_ECC_DIGITS, curve_p);    /* t1 = x1^2 - z1^4 */
    
    vli_modAdd(Z1, X1, X1, curve_p, NUM_ECC_DIGITS); /* t3 = 2*(x1^2 - z1^4) */
    vli_modAdd(X1, X1, Z1, curve_p, NUM_ECC_DIGITS); /* t1 = 3*(x1^2 - z1^4) */
    if(vli_testBit(X1, 0))
    {
        uint64_t l_carry = vli_add(X1, X1, curve_p, NUM_ECC_DIGITS);
        vli_rshift1(X1, NUM_ECC_DIGITS);
        X1[NUM_ECC_DIGITS-1] |= l_carry << 63;
    }
    else
    {
        vli_rshift1(X1, NUM_ECC_DIGITS);
    }
    /* t1 = 3/2*(x1^2 - z1^4) = B */
    
    vli_modSquare_fast(Z1, X1, NUM_ECC_DIGITS, curve_p);      /* t3 = B^2 */
    vli_modSub(Z1, Z1, t5, curve_p, NUM_ECC_DIGITS); /* t3 = B^2 - A */
    vli_modSub(Z1, Z1, t5, curve_p, NUM_ECC_DIGITS); /* t3 = B^2 - 2A = x3 */
    vli_modSub(t5, t5, Z1, curve_p, NUM_ECC_DIGITS); /* t5 = A - x3 */
    vli_modMult_fast(X1, X1, t5, NUM_ECC_DIGITS, curve_p);    /* t1 = B * (A - x3) */
    vli_modSub(t4, X1, t4, curve_p, NUM_ECC_DIGITS); /* t4 = B * (A - x3) - y1^4 = y3 */
    
    vli_set(X1, Z1, NUM_ECC_DIGITS);
    vli_set(Z1, Y1, NUM_ECC_DIGITS);
    vli_set(Y1, t4, NUM_ECC_DIGITS);
}

/* Modify (x1, y1) => (x1 * z^2, y1 * z^3) */
static void apply_z(uint64_t *X1, uint64_t *Y1, uint64_t *Z, int NUM_ECC_DIGITS, uint64_t *curve_p)
{
    uint64_t t1[NUM_ECC_DIGITS];
    
    vli_modSquare_fast(t1, Z, NUM_ECC_DIGITS, curve_p);    /* z^2 */
    vli_modMult_fast(X1, X1, t1, NUM_ECC_DIGITS, curve_p); /* x1 * z^2 */
    vli_modMult_fast(t1, t1, Z, NUM_ECC_DIGITS, curve_p);  /* z^3 */
    vli_modMult_fast(Y1, Y1, t1, NUM_ECC_DIGITS, curve_p); /* y1 * z^3 */
}

/* P = (x1, y1) => 2P, (x2, y2) => P' */
static void XYcZ_initial_double(uint64_t *X1, uint64_t *Y1, uint64_t *X2, uint64_t *Y2, uint64_t *p_initialZ, int NUM_ECC_DIGITS, uint64_t *curve_p)
{
    uint64_t z[NUM_ECC_DIGITS];
    
    vli_set(X2, X1, NUM_ECC_DIGITS);
    vli_set(Y2, Y1, NUM_ECC_DIGITS);
    
    vli_clear(z, NUM_ECC_DIGITS);
    z[0] = 1;
    if(p_initialZ)
    {
        vli_set(z, p_initialZ, NUM_ECC_DIGITS);
    }
    
    apply_z(X1, Y1, z, NUM_ECC_DIGITS, curve_p);
    
    EccPoint_double_jacobian(X1, Y1, z, NUM_ECC_DIGITS, curve_p);
    
    apply_z(X2, Y2, z, NUM_ECC_DIGITS, curve_p);
}

/* Input P = (x1, y1, Z), Q = (x2, y2, Z)
 Output P' = (x1', y1', Z3), P + Q = (x3, y3, Z3)
 or P => P', Q => P + Q
 */
static void XYcZ_add(uint64_t *X1, uint64_t *Y1, uint64_t *X2, uint64_t *Y2, int NUM_ECC_DIGITS, uint64_t *curve_p)
{
    /* t1 = X1, t2 = Y1, t3 = X2, t4 = Y2 */
    uint64_t t5[NUM_ECC_DIGITS];
    
    vli_modSub(t5, X2, X1, curve_p, NUM_ECC_DIGITS); /* t5 = x2 - x1 */
    vli_modSquare_fast(t5, t5, NUM_ECC_DIGITS, curve_p);      /* t5 = (x2 - x1)^2 = A */
    vli_modMult_fast(X1, X1, t5, NUM_ECC_DIGITS, curve_p);    /* t1 = x1*A = B */
    vli_modMult_fast(X2, X2, t5, NUM_ECC_DIGITS, curve_p);    /* t3 = x2*A = C */
    vli_modSub(Y2, Y2, Y1, curve_p, NUM_ECC_DIGITS); /* t4 = y2 - y1 */
    vli_modSquare_fast(t5, Y2, NUM_ECC_DIGITS, curve_p);      /* t5 = (y2 - y1)^2 = D */
    
    vli_modSub(t5, t5, X1, curve_p, NUM_ECC_DIGITS); /* t5 = D - B */
    vli_modSub(t5, t5, X2, curve_p, NUM_ECC_DIGITS); /* t5 = D - B - C = x3 */
    vli_modSub(X2, X2, X1, curve_p, NUM_ECC_DIGITS); /* t3 = C - B */
    vli_modMult_fast(Y1, Y1, X2, NUM_ECC_DIGITS, curve_p);    /* t2 = y1*(C - B) */
    vli_modSub(X2, X1, t5, curve_p, NUM_ECC_DIGITS); /* t3 = B - x3 */
    vli_modMult_fast(Y2, Y2, X2, NUM_ECC_DIGITS, curve_p);    /* t4 = (y2 - y1)*(B - x3) */
    vli_modSub(Y2, Y2, Y1, curve_p, NUM_ECC_DIGITS); /* t4 = y3 */
    
    vli_set(X2, t5, NUM_ECC_DIGITS);
}

/* Input P = (x1, y1, Z), Q = (x2, y2, Z)
 Output P + Q = (x3, y3, Z3), P - Q = (x3', y3', Z3)
 or P => P - Q, Q => P + Q
 */
static void XYcZ_addC(uint64_t *X1, uint64_t *Y1, uint64_t *X2, uint64_t *Y2, int NUM_ECC_DIGITS, uint64_t *curve_p)
{
    /* t1 = X1, t2 = Y1, t3 = X2, t4 = Y2 */
    uint64_t t5[NUM_ECC_DIGITS];
    uint64_t t6[NUM_ECC_DIGITS];
    uint64_t t7[NUM_ECC_DIGITS];
    
    vli_modSub(t5, X2, X1, curve_p, NUM_ECC_DIGITS); /* t5 = x2 - x1 */
    vli_modSquare_fast(t5, t5, NUM_ECC_DIGITS, curve_p);      /* t5 = (x2 - x1)^2 = A */
    vli_modMult_fast(X1, X1, t5, NUM_ECC_DIGITS, curve_p);    /* t1 = x1*A = B */
    vli_modMult_fast(X2, X2, t5, NUM_ECC_DIGITS, curve_p);    /* t3 = x2*A = C */
    vli_modAdd(t5, Y2, Y1, curve_p, NUM_ECC_DIGITS); /* t4 = y2 + y1 */
    vli_modSub(Y2, Y2, Y1, curve_p, NUM_ECC_DIGITS); /* t4 = y2 - y1 */
    
    vli_modSub(t6, X2, X1, curve_p, NUM_ECC_DIGITS); /* t6 = C - B */
    vli_modMult_fast(Y1, Y1, t6, NUM_ECC_DIGITS, curve_p);    /* t2 = y1 * (C - B) */
    vli_modAdd(t6, X1, X2, curve_p, NUM_ECC_DIGITS); /* t6 = B + C */
    vli_modSquare_fast(X2, Y2, NUM_ECC_DIGITS, curve_p);      /* t3 = (y2 - y1)^2 */
    vli_modSub(X2, X2, t6, curve_p, NUM_ECC_DIGITS); /* t3 = x3 */
    
    vli_modSub(t7, X1, X2, curve_p, NUM_ECC_DIGITS); /* t7 = B - x3 */
    vli_modMult_fast(Y2, Y2, t7, NUM_ECC_DIGITS, curve_p);    /* t4 = (y2 - y1)*(B - x3) */
    vli_modSub(Y2, Y2, Y1, curve_p, NUM_ECC_DIGITS); /* t4 = y3 */
    
    vli_modSquare_fast(t7, t5, NUM_ECC_DIGITS, curve_p);      /* t7 = (y2 + y1)^2 = F */
    vli_modSub(t7, t7, t6, curve_p, NUM_ECC_DIGITS); /* t7 = x3' */
    vli_modSub(t6, t7, X1, curve_p, NUM_ECC_DIGITS); /* t6 = x3' - B */
    vli_modMult_fast(t6, t6, t5, NUM_ECC_DIGITS, curve_p);    /* t6 = (y2 + y1)*(x3' - B) */
    vli_modSub(Y1, t6, Y1, curve_p, NUM_ECC_DIGITS); /* t2 = y3' */
    
    vli_set(X1, t7, NUM_ECC_DIGITS);
}

static void EccPoint_mult(uint64_t *p_resultX, uint64_t *p_resultY, uint64_t *p_pointX, uint64_t *p_pointY, uint64_t *p_scalar, uint64_t *p_initialZ, int p_numBits, int NUM_ECC_DIGITS, uint64_t *curve_p)
//static void EccPoint_mult(EccPoint *p_result, EccPoint *p_point, uint64_t *p_scalar, uint64_t *p_initialZ, int p_numBits)
{
    /* R0 and R1 */
    uint64_t Rx[2][NUM_ECC_DIGITS];
    uint64_t Ry[2][NUM_ECC_DIGITS];
    uint64_t z[NUM_ECC_DIGITS];
    
    int i, nb;
    
    vli_set(Rx[1], p_pointX, NUM_ECC_DIGITS);
    vli_set(Ry[1], p_pointY, NUM_ECC_DIGITS);
    
    XYcZ_initial_double(Rx[1], Ry[1], Rx[0], Ry[0], p_initialZ, NUM_ECC_DIGITS, curve_p);
    
    for(i = p_numBits - 2; i > 0; --i)
    {
        nb = !vli_testBit(p_scalar, i);
        XYcZ_addC(Rx[1-nb], Ry[1-nb], Rx[nb], Ry[nb], NUM_ECC_DIGITS, curve_p);
        XYcZ_add(Rx[nb], Ry[nb], Rx[1-nb], Ry[1-nb], NUM_ECC_DIGITS, curve_p);
    }
    
    nb = !vli_testBit(p_scalar, 0);
    XYcZ_addC(Rx[1-nb], Ry[1-nb], Rx[nb], Ry[nb], NUM_ECC_DIGITS, curve_p);
    
    /* Find final 1/Z value. */
    vli_modSub(z, Rx[1], Rx[0], curve_p, NUM_ECC_DIGITS); /* X1 - X0 */
    vli_modMult_fast(z, z, Ry[1-nb], NUM_ECC_DIGITS, curve_p);     /* Yb * (X1 - X0) */
    vli_modMult_fast(z, z, p_pointX, NUM_ECC_DIGITS, curve_p);   /* xP * Yb * (X1 - X0) */
    vli_modInv(z, z, curve_p, NUM_ECC_DIGITS);            /* 1 / (xP * Yb * (X1 - X0)) */
    vli_modMult_fast(z, z, p_pointY, NUM_ECC_DIGITS, curve_p);   /* yP / (xP * Yb * (X1 - X0)) */
    vli_modMult_fast(z, z, Rx[1-nb], NUM_ECC_DIGITS, curve_p);     /* Xb * yP / (xP * Yb * (X1 - X0)) */
    /* End 1/Z calculation */
    
    XYcZ_add(Rx[nb], Ry[nb], Rx[1-nb], Ry[1-nb], NUM_ECC_DIGITS, curve_p);
    
    apply_z(Rx[0], Ry[0], z, NUM_ECC_DIGITS, curve_p);
    
    vli_set(p_resultX, Rx[0], NUM_ECC_DIGITS);
    vli_set(p_resultY, Ry[0], NUM_ECC_DIGITS);
}

static void ecc_bytes2native(uint64_t *p_native, const uint8_t *p_bytes, int NUM_ECC_DIGITS)
//static void ecc_bytes2native(uint64_t p_native[NUM_ECC_DIGITS], const uint8_t p_bytes[ECC_BYTES])
{
    unsigned i;
    for(i=0; i<NUM_ECC_DIGITS; ++i)
    {
        const uint8_t *p_digit = p_bytes + 8 * (NUM_ECC_DIGITS - 1 - i);
        p_native[i] = ((uint64_t)p_digit[0] << 56) | ((uint64_t)p_digit[1] << 48) | ((uint64_t)p_digit[2] << 40) | ((uint64_t)p_digit[3] << 32) |
        ((uint64_t)p_digit[4] << 24) | ((uint64_t)p_digit[5] << 16) | ((uint64_t)p_digit[6] << 8) | (uint64_t)p_digit[7];
    }
}

static void ecc_native2bytes(uint8_t *p_bytes, const uint64_t *p_native, int NUM_ECC_DIGITS)
//static void ecc_native2bytes(uint8_t p_bytes[ECC_BYTES], const uint64_t p_native[NUM_ECC_DIGITS])
{
    unsigned i;
    for(i=0; i<NUM_ECC_DIGITS; ++i)
    {
        uint8_t *p_digit = p_bytes + 8 * (NUM_ECC_DIGITS - 1 - i);
        p_digit[0] = p_native[i] >> 56;
        p_digit[1] = p_native[i] >> 48;
        p_digit[2] = p_native[i] >> 40;
        p_digit[3] = p_native[i] >> 32;
        p_digit[4] = p_native[i] >> 24;
        p_digit[5] = p_native[i] >> 16;
        p_digit[6] = p_native[i] >> 8;
        p_digit[7] = p_native[i];
    }
}

/* Compute a = sqrt(a) (mod curve_p). */
static void mod_sqrt(uint64_t *a, int NUM_ECC_DIGITS, uint64_t *curve_p)
//static void mod_sqrt(uint64_t a[NUM_ECC_DIGITS])
{
    unsigned i;
    uint64_t p1[NUM_ECC_DIGITS];
    uint64_t l_result[NUM_ECC_DIGITS];
    p1[0] = 1;
    l_result[0] = 1;
    for (int i = 1; i < NUM_ECC_DIGITS; i++) {
        p1[i] = l_result[i] = 0;
    }

//    uint64_t p1[NUM_ECC_DIGITS] = {1};
//    uint64_t l_result[NUM_ECC_DIGITS] = {1};

    /* Since curve_p == 3 (mod 4) for all supported curves, we can
     compute sqrt(a) = a^((curve_p + 1) / 4) (mod curve_p). */
    vli_add(p1, curve_p, p1, NUM_ECC_DIGITS); /* p1 = curve_p + 1 */
    for(i = vli_numBits(p1, NUM_ECC_DIGITS) - 1; i > 1; --i)
    {
        vli_modSquare_fast(l_result, l_result, NUM_ECC_DIGITS, curve_p);
        if(vli_testBit(p1, i))
        {
            vli_modMult_fast(l_result, l_result, a, NUM_ECC_DIGITS, curve_p);
        }
    }
    vli_set(a, l_result, NUM_ECC_DIGITS);
}

static void ecc_point_decompress(uint64_t *p_pointX, uint64_t *p_pointY, const uint8_t *p_compressed, int NUM_ECC_DIGITS, uint64_t *curve_p, uint64_t *curve_b)
//static void ecc_point_decompress(EccPoint *p_point, const uint8_t p_compressed[ECC_BYTES+1])
{
    uint64_t _3[NUM_ECC_DIGITS]; /* -a = 3 */
    _3[0] = 3;
    for (int i = 1; i < NUM_ECC_DIGITS; i++) {
        _3[i] = 0;
    }
    
    //uint64_t _3[NUM_ECC_DIGITS] = {3}; /* -a = 3 */
    ecc_bytes2native(p_pointX, p_compressed+1, NUM_ECC_DIGITS);
    
    vli_modSquare_fast(p_pointY, p_pointX, NUM_ECC_DIGITS, curve_p); /* y = x^2 */
    vli_modSub(p_pointY, p_pointY, _3, curve_p, NUM_ECC_DIGITS); /* y = x^2 - 3 */
    vli_modMult_fast(p_pointY, p_pointY, p_pointX, NUM_ECC_DIGITS, curve_p); /* y = x^3 - 3x */
    vli_modAdd(p_pointY, p_pointY, curve_b, curve_p, NUM_ECC_DIGITS); /* y = x^3 - 3x + b */
    
    mod_sqrt(p_pointY, NUM_ECC_DIGITS, curve_p);
    
    if((p_pointY[0] & 0x01) != (p_compressed[0] & 0x01))
    {
        vli_sub(p_pointY, curve_p, p_pointY, NUM_ECC_DIGITS);
    }
}

int ecc_make_key(uint8_t *p_publicKey, uint8_t *p_privateKey, int NUM_ECC_DIGITS, uint64_t *curve_p, uint64_t *curve_n, uint64_t *curve_GX, uint64_t *curve_GY)
//int ecc_make_key(uint8_t p_publicKey[ECC_BYTES+1], uint8_t p_privateKey[ECC_BYTES])
{
    uint64_t l_private[NUM_ECC_DIGITS];
    uint64_t l_publicX[NUM_ECC_DIGITS], l_publicY[NUM_ECC_DIGITS];
    //EccPoint l_public;
    unsigned l_tries = 0;
    
    do
    {
        if(!getRandomNumber(l_private, NUM_ECC_DIGITS) || (l_tries++ >= MAX_TRIES))
        {
            return 0;
        }
        if(vli_isZero(l_private, NUM_ECC_DIGITS))
        {
            continue;
        }
        
        /* Make sure the private key is in the range [1, n-1]. */
        if(vli_cmp(curve_n, l_private, NUM_ECC_DIGITS) != 1)
        {
            continue;
        }
        
        EccPoint_mult(l_publicX, l_publicY, curve_GX, curve_GY, l_private, NULL, vli_numBits(l_private, NUM_ECC_DIGITS), NUM_ECC_DIGITS, curve_p);
        //EccPoint_mult(&l_public, &curve_G, l_private, NULL, vli_numBits(l_private));

    } while(EccPoint_isZero(l_publicX, l_publicY, NUM_ECC_DIGITS));
    //} while(EccPoint_isZero(&l_public, NUM_ECC_DIGITS));

    ecc_native2bytes(p_privateKey, l_private, NUM_ECC_DIGITS);
    ecc_native2bytes(p_publicKey + 1, l_publicX, NUM_ECC_DIGITS);
    p_publicKey[0] = 2 + (l_publicY[0] & 0x01);
    return 1;
}

int ecdh_shared_secret(const uint8_t *p_publicKey, const uint8_t *p_privateKey, uint8_t *p_secret, int NUM_ECC_DIGITS, uint64_t *curve_p, uint64_t *curve_b)
//int ecdh_shared_secret(const uint8_t p_publicKey[ECC_BYTES+1], const uint8_t p_privateKey[ECC_BYTES], uint8_t p_secret[ECC_BYTES])
{
    uint64_t l_publicX[NUM_ECC_DIGITS], l_publicY[NUM_ECC_DIGITS];
    uint64_t l_private[NUM_ECC_DIGITS];
    uint64_t l_random[NUM_ECC_DIGITS];
    
    if(!getRandomNumber(l_random, NUM_ECC_DIGITS))
    {
        return 0;
    }
    
    ecc_point_decompress(l_publicX, l_publicY, p_publicKey, NUM_ECC_DIGITS, curve_p, curve_b);
    ecc_bytes2native(l_private, p_privateKey, NUM_ECC_DIGITS);
    
    uint64_t l_productX[NUM_ECC_DIGITS], l_productY[NUM_ECC_DIGITS];
    EccPoint_mult(l_productX, l_productY, l_publicX, l_publicY, l_private, l_random, vli_numBits(l_private, NUM_ECC_DIGITS), NUM_ECC_DIGITS, curve_p);
    
    ecc_native2bytes(p_secret, l_productX, NUM_ECC_DIGITS);
    
    return !EccPoint_isZero(l_productX, l_productY, NUM_ECC_DIGITS);
}

/* -------- ECDSA code -------- */

/* Computes p_vli = p_vli >> 1. */
static void vli2_rshift1(uint64_t *p_vli, int NUM_ECC_DIGITS)
{
    uint64_t *l_end = p_vli;
    uint64_t l_carry = 0;
    
    p_vli += NUM_ECC_DIGITS*2;
    while(p_vli-- > l_end)
    {
        uint64_t l_temp = *p_vli;
        *p_vli = (l_temp >> 1) | l_carry;
        l_carry = l_temp << 63;
    }
}

/* Computes p_result = p_left - p_right, returning borrow. Can modify in place. */
static uint64_t vli2_sub(uint64_t *p_result, uint64_t *p_left, uint64_t *p_right, int NUM_ECC_DIGITS)
{
    uint64_t l_borrow = 0;
    uint i;
    for(i=0; i<NUM_ECC_DIGITS*2; ++i)
    {
        uint64_t l_diff = p_left[i] - p_right[i] - l_borrow;
        if(l_diff != p_left[i])
        {
            l_borrow = (l_diff > p_left[i]);
        }
        p_result[i] = l_diff;
    }
    return l_borrow;
}

/* Computes p_result = (p_left * p_right) % p_mod. */
static void vli_modMult(uint64_t *p_result, uint64_t *p_left, uint64_t *p_right, uint64_t *p_mod, int NUM_ECC_DIGITS)
{
    uint64_t l_product[2 * NUM_ECC_DIGITS];
    uint64_t l_modMultiple[2 * NUM_ECC_DIGITS];
    uint64_t l_tmp[2 * NUM_ECC_DIGITS];
    uint64_t *v[2] = {l_tmp, l_product};
    
    vli_mult(l_product, p_left, p_right, NUM_ECC_DIGITS);
    vli_set(l_modMultiple + NUM_ECC_DIGITS, p_mod, NUM_ECC_DIGITS);
    vli_clear(l_modMultiple, NUM_ECC_DIGITS);
    
    uint i;
    uint l_index = 1;
    for(i=0; i<=NUM_ECC_DIGITS * 64; ++i)
    {
        uint l_borrow = (uint)vli2_sub(v[1-l_index], v[l_index], l_modMultiple, NUM_ECC_DIGITS);    /// Cast by RicMoo
        l_index = !(l_index ^ l_borrow); /* Swap the index if there was no borrow */
        vli2_rshift1(l_modMultiple, NUM_ECC_DIGITS);
    }
    
    vli_set(p_result, v[l_index], NUM_ECC_DIGITS);
}

static uint umax(uint a, uint b)
{
    return (a > b ? a : b);
}

int ecdsa_sign(const uint8_t *p_privateKey, const uint8_t *p_hash, uint8_t *p_signature, int NUM_ECC_DIGITS, uint64_t *curve_p, uint64_t *curve_n, uint64_t *curve_GX, uint64_t *curve_GY)
//int ecdsa_sign(const uint8_t p_privateKey[ECC_BYTES], const uint8_t p_hash[ECC_BYTES], uint8_t p_signature[ECC_BYTES*2])
{
    int ECC_BYTES = NUM_ECC_DIGITS * 8;
    
    uint64_t k[NUM_ECC_DIGITS];
    uint64_t l_tmp[NUM_ECC_DIGITS];
    uint64_t s[NUM_ECC_DIGITS];
    uint64_t *k2[2] = {l_tmp, s};
    uint64_t pX[NUM_ECC_DIGITS], pY[NUM_ECC_DIGITS];
    unsigned l_tries = 0;
    
    do
    {
        if(!getRandomNumber(k, NUM_ECC_DIGITS) || (l_tries++ >= MAX_TRIES))
        {
            return 0;
        }
        if(vli_isZero(k, NUM_ECC_DIGITS))
        {
            continue;
        }
        
        if(vli_cmp(curve_n, k, NUM_ECC_DIGITS) != 1)
        {
            continue;
        }
        
        /* make sure that we don't leak timing information about k. See http://eprint.iacr.org/2011/232.pdf */
        uint64_t l_carry = vli_add(l_tmp, k, curve_n, NUM_ECC_DIGITS);
        vli_add(s, l_tmp, curve_n, NUM_ECC_DIGITS);
        
        /* p = k * G */
        EccPoint_mult(pX, pY, curve_GX, curve_GY, k2[!l_carry], NULL, (ECC_BYTES * 8) + 1, NUM_ECC_DIGITS, curve_p);
        
        /* r = x1 (mod n) */
        if(vli_cmp(curve_n, pX, NUM_ECC_DIGITS) != 1)
        {
            vli_sub(pX, pX, curve_n, NUM_ECC_DIGITS);
        }
    } while(vli_isZero(pX, NUM_ECC_DIGITS));
    
    do
    {
        if(!getRandomNumber(l_tmp, NUM_ECC_DIGITS) || (l_tries++ >= MAX_TRIES))
        {
            return 0;
        }
    } while(vli_isZero(l_tmp, NUM_ECC_DIGITS));
    /* Prevent side channel analysis of vli_modInv() to determine
     bits of k / the private key by premultiplying by a random number */
    vli_modMult(k, k, l_tmp, curve_n, NUM_ECC_DIGITS); /* k' = rand * k */
    vli_modInv(k, k, curve_n, NUM_ECC_DIGITS); /* k = 1 / k' */
    vli_modMult(k, k, l_tmp, curve_n, NUM_ECC_DIGITS); /* k = 1 / k */
    
    ecc_native2bytes(p_signature, pX, NUM_ECC_DIGITS); /* store r */
    
    ecc_bytes2native(l_tmp, p_privateKey, NUM_ECC_DIGITS); /* tmp = d */
    vli_modMult(s, l_tmp, pX, curve_n, NUM_ECC_DIGITS); /* s = r*d */
    
    ecc_bytes2native(l_tmp, p_hash, NUM_ECC_DIGITS);
    vli_modAdd(s, l_tmp, s, curve_n, NUM_ECC_DIGITS); /* s = e + r*d */
    vli_modMult(s, s, k, curve_n, NUM_ECC_DIGITS); /* s = (e + r*d) / k */
    ecc_native2bytes(p_signature + ECC_BYTES, s, NUM_ECC_DIGITS);
    
    return 1;
}

static void clear_ecc_point(uint64_t *dstX, uint64_t *dstY, int length) {
    for (int i = 0; i < length; i++) {
        dstX[i] = 0;
        dstY[i] = 0;
    }
}

static void copy_ecc_point(uint64_t *dstX, uint64_t *dstY, uint64_t *srcX, uint64_t *srcY, int length) {
    for (int i = 0; i < length; i++) {
        dstX[i] = srcX[i];
        dstY[i] = srcY[i];
    }
}

int ecdsa_verify(const uint8_t *p_publicKey, const uint8_t *p_hash, const uint8_t *p_signature, int NUM_ECC_DIGITS, uint64_t *curve_p, uint64_t *curve_b, uint64_t *curve_n, uint64_t *curve_GX, uint64_t *curve_GY)
//int ecdsa_verify(const uint8_t p_publicKey[ECC_BYTES+1], const uint8_t p_hash[ECC_BYTES], const uint8_t p_signature[ECC_BYTES*2])
{
    int ECC_BYTES = NUM_ECC_DIGITS * 8;
    
    uint64_t u1[NUM_ECC_DIGITS], u2[NUM_ECC_DIGITS];
    uint64_t z[NUM_ECC_DIGITS];
    uint64_t l_publicX[NUM_ECC_DIGITS], l_publicY[NUM_ECC_DIGITS], l_sumX[NUM_ECC_DIGITS], l_sumY[NUM_ECC_DIGITS];
    uint64_t rx[NUM_ECC_DIGITS];
    uint64_t ry[NUM_ECC_DIGITS];
    uint64_t tx[NUM_ECC_DIGITS];
    uint64_t ty[NUM_ECC_DIGITS];
    uint64_t tz[NUM_ECC_DIGITS];
    
    uint64_t l_r[NUM_ECC_DIGITS], l_s[NUM_ECC_DIGITS];
    
    ecc_point_decompress(l_publicX, l_publicY, p_publicKey, NUM_ECC_DIGITS, curve_p, curve_b);
    ecc_bytes2native(l_r, p_signature, NUM_ECC_DIGITS);
    ecc_bytes2native(l_s, p_signature + ECC_BYTES, NUM_ECC_DIGITS);
    
    if(vli_isZero(l_r, NUM_ECC_DIGITS) || vli_isZero(l_s, NUM_ECC_DIGITS))
    { /* r, s must not be 0. */
        return 0;
    }
    
    if(vli_cmp(curve_n, l_r, NUM_ECC_DIGITS) != 1 || vli_cmp(curve_n, l_s, NUM_ECC_DIGITS) != 1)
    { /* r, s must be < n. */
        return 0;
    }
    
    /* Calculate u1 and u2. */
    vli_modInv(z, l_s, curve_n, NUM_ECC_DIGITS); /* Z = s^-1 */
    ecc_bytes2native(u1, p_hash, NUM_ECC_DIGITS);
    vli_modMult(u1, u1, z, curve_n, NUM_ECC_DIGITS); /* u1 = e/s */
    vli_modMult(u2, l_r, z, curve_n, NUM_ECC_DIGITS); /* u2 = r/s */
    
    /* Calculate l_sum = G + Q. */
    vli_set(l_sumX, l_publicX, NUM_ECC_DIGITS);
    vli_set(l_sumY, l_publicY, NUM_ECC_DIGITS);
    vli_set(tx, curve_GX, NUM_ECC_DIGITS);
    vli_set(ty, curve_GY, NUM_ECC_DIGITS);
    vli_modSub(z, l_sumX, tx, curve_p, NUM_ECC_DIGITS); /* Z = x2 - x1 */
    XYcZ_add(tx, ty, l_sumX, l_sumY, NUM_ECC_DIGITS, curve_p);
    vli_modInv(z, z, curve_p, NUM_ECC_DIGITS); /* Z = 1/Z */
    apply_z(l_sumX, l_sumY, z, NUM_ECC_DIGITS, curve_p);
    
    /* Use Shamir's trick to calculate u1*G + u2*Q */
    uint64_t l_pointsX[4 * NUM_ECC_DIGITS];
    uint64_t l_pointsY[4 * NUM_ECC_DIGITS];
    clear_ecc_point(&l_pointsX[0 * NUM_ECC_DIGITS], &l_pointsY[0 * NUM_ECC_DIGITS], NUM_ECC_DIGITS);
    copy_ecc_point(&l_pointsX[1 * NUM_ECC_DIGITS], &l_pointsY[1 * NUM_ECC_DIGITS], curve_GX, curve_GY, NUM_ECC_DIGITS);
    copy_ecc_point(&l_pointsX[2 * NUM_ECC_DIGITS], &l_pointsY[2 * NUM_ECC_DIGITS], l_publicX, l_publicY, NUM_ECC_DIGITS);
    copy_ecc_point(&l_pointsX[3 * NUM_ECC_DIGITS], &l_pointsY[3 * NUM_ECC_DIGITS], l_sumX, l_sumY, NUM_ECC_DIGITS);
    //EccPoint *l_points[4] = {NULL, &curve_G, &l_public, &l_sum};
    
    uint l_numBits = umax(vli_numBits(u1, NUM_ECC_DIGITS), vli_numBits(u2, NUM_ECC_DIGITS));
    
    uint64_t l_pointX[NUM_ECC_DIGITS];
    uint64_t l_pointY[NUM_ECC_DIGITS];
    int l_pointIndex = (!!vli_testBit(u1, l_numBits-1)) | ((!!vli_testBit(u2, l_numBits-1)) << 1);
    copy_ecc_point(l_pointX, l_pointY, &l_pointsX[l_pointIndex * NUM_ECC_DIGITS], &l_pointsY[l_pointIndex * NUM_ECC_DIGITS], NUM_ECC_DIGITS);
    //EccPoint *l_point = l_points[(!!vli_testBit(u1, l_numBits-1)) | ((!!vli_testBit(u2, l_numBits-1)) << 1)];
    
    vli_set(rx, l_pointX, NUM_ECC_DIGITS);
    vli_set(ry, l_pointY, NUM_ECC_DIGITS);
    vli_clear(z, NUM_ECC_DIGITS);
    z[0] = 1;
    
    int i;
    for(i = l_numBits - 2; i >= 0; --i)
    {
        EccPoint_double_jacobian(rx, ry, z, NUM_ECC_DIGITS, curve_p);
        
        int l_index = (!!vli_testBit(u1, i)) | ((!!vli_testBit(u2, i)) << 1);
        copy_ecc_point(l_pointX, l_pointY, &l_pointsX[l_index * NUM_ECC_DIGITS], &l_pointsY[l_index * NUM_ECC_DIGITS], NUM_ECC_DIGITS);
        //l_point = l_points[l_index];
        if(l_index)
        //if(l_point)
        {
            vli_set(tx, l_pointX, NUM_ECC_DIGITS);
            vli_set(ty, l_pointY, NUM_ECC_DIGITS);
            apply_z(tx, ty, z, NUM_ECC_DIGITS, curve_p);
            vli_modSub(tz, rx, tx, curve_p, NUM_ECC_DIGITS); /* Z = x2 - x1 */
            XYcZ_add(tx, ty, rx, ry, NUM_ECC_DIGITS, curve_p);
            vli_modMult_fast(z, z, tz, NUM_ECC_DIGITS, curve_p);
        }
    }
    
    vli_modInv(z, z, curve_p, NUM_ECC_DIGITS); /* Z = 1/Z */
    apply_z(rx, ry, z, NUM_ECC_DIGITS, curve_p);
    
    /* v = x1 (mod n) */
    if(vli_cmp(curve_n, rx, NUM_ECC_DIGITS) != 1)
    {
        vli_sub(rx, rx, curve_n, NUM_ECC_DIGITS);
    }
    
    /* Accept only if v == r. */
    return (vli_cmp(rx, l_r, NUM_ECC_DIGITS) == 0);
}


// secp128r1
static uint64_t Curve_p_128[2] = {0xFFFFFFFFFFFFFFFF, 0xFFFFFFFDFFFFFFFF};
static uint64_t Curve_b_128[2] = {0xD824993C2CEE5ED3, 0xE87579C11079F43D};
static uint64_t Curve_Gx_128[2] = {0x0C28607CA52C5B86, 0x161FF7528B899B2D};
static uint64_t Curve_Gy_128[2] = {0xC02DA292DDED7A83, 0xCF5AC8395BAFEB13};
static uint64_t Curve_n_128[2] = {0x75A30D1B9038A115, 0xFFFFFFFE00000000};

// secp192r1
static uint64_t Curve_p_192[3] = {0xFFFFFFFFFFFFFFFFull, 0xFFFFFFFFFFFFFFFEull, 0xFFFFFFFFFFFFFFFFull};
static uint64_t Curve_b_192[3] = {0xFEB8DEECC146B9B1ull, 0x0FA7E9AB72243049ull, 0x64210519E59C80E7ull};
static uint64_t Curve_Gx_192[3] = {0xF4FF0AFD82FF1012ull, 0x7CBF20EB43A18800ull, 0x188DA80EB03090F6ull};
static uint64_t Curve_Gy_192[3] = {0x73F977A11E794811ull, 0x631011ED6B24CDD5ull, 0x07192B95FFC8DA78ull};
static uint64_t Curve_n_192[3] = {0x146BC9B1B4D22831ull, 0xFFFFFFFF99DEF836ull, 0xFFFFFFFFFFFFFFFFull};

// secp256r1
static uint64_t Curve_p_256[4] = {0xFFFFFFFFFFFFFFFFull, 0x00000000FFFFFFFFull, 0x0000000000000000ull, 0xFFFFFFFF00000001ull};
static uint64_t Curve_b_256[4] = {0x3BCE3C3E27D2604Bull, 0x651D06B0CC53B0F6ull, 0xB3EBBD55769886BCull, 0x5AC635D8AA3A93E7ull};
static uint64_t Curve_Gx_256[4] = {0xF4A13945D898C296ull, 0x77037D812DEB33A0ull, 0xF8BCE6E563A440F2ull, 0x6B17D1F2E12C4247ull};
static uint64_t Curve_Gy_256[4] = {0xCBB6406837BF51F5ull, 0x2BCE33576B315ECEull, 0x8EE7EB4A7C0F9E16ull, 0x4FE342E2FE1A7F9Bull};
static uint64_t Curve_n_256[4] = {0xF3B9CAC2FC632551ull, 0xBCE6FAADA7179E84ull, 0xFFFFFFFFFFFFFFFFull, 0xFFFFFFFF00000000ull};

// secp384r1
static uint64_t Curve_p_384[6] = {0x00000000FFFFFFFF, 0xFFFFFFFF00000000, 0xFFFFFFFFFFFFFFFE, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF};
static uint64_t Curve_b_384[6] = {0x2A85C8EDD3EC2AEF, 0xC656398D8A2ED19D, 0x0314088F5013875A, 0x181D9C6EFE814112, 0x988E056BE3F82D19, 0xB3312FA7E23EE7E4};
static uint64_t Curve_Gx_384[6] = {0x3A545E3872760AB7, 0x5502F25DBF55296C, 0x59F741E082542A38, 0x6E1D3B628BA79B98, 0x8EB1C71EF320AD74, 0xAA87CA22BE8B0537};
static uint64_t Curve_Gy_384[6] = {0x7A431D7C90EA0E5F, 0x0A60B1CE1D7E819D, 0xE9DA3113B5F0B8C0, 0xF8F41DBD289A147C, 0x5D9E98BF9292DC29, 0x3617DE4A96262C6F};
static uint64_t Curve_n_384[6] = {0xECEC196ACCC52973, 0x581A0DB248B0A77A, 0xC7634D81F4372DDF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF};


/* end of ecc.c */



@interface GMEllipticCurveCrypto () {
    int _bytes, _numDigits;
    uint64_t *_curve_p, *_curve_b, *_curve_Gx, *_curve_Gy, *_curve_n;
    NSData *_publicKey;
}

@end


@implementation GMEllipticCurveCrypto


+ (GMEllipticCurveCrypto*)generateKeyPairForCurve:(GMEllipticCurve)curve {
    GMEllipticCurveCrypto *crypto = [[self alloc] initWithCurve:curve];
    [crypto generateNewKeyPair];
    return crypto;
    
}

+ (GMEllipticCurve)curveForKey:(NSData *)privateOrPublicKey {

    NSInteger length = [privateOrPublicKey length];

    // We need at least 1 byte
    if (length == 0) {
        return GMEllipticCurveNone;
    }

    const uint8_t *bytes = [privateOrPublicKey bytes];

    // Odd-length, therefore a public key
    if (length % 2) {
        switch (bytes[0]) {
            case 0x04:
                length = (length - 1) / 2;
                break;
            case 0x02: case 0x03:
                length--;
                break;
            default:
                return GMEllipticCurveNone;
        }
    }

    switch (length) {
        case 16:
            return GMEllipticCurveSecp128r1;
        case 24:
            return GMEllipticCurveSecp192r1;
        case 32:
            return GMEllipticCurveSecp256r1;
        case 48:
            return GMEllipticCurveSecp384r1;
    }

    return GMEllipticCurveNone;
}


+ (GMEllipticCurve)curveForKeyBase64:(NSString *)privateOrPublicKey {
    return [self curveForKey:[[NSData alloc] initWithBase64EncodedString:privateOrPublicKey options:0]];
}


+ (GMEllipticCurveCrypto*)cryptoForKey:(NSData *)privateOrPublicKey {
    GMEllipticCurve curve = [self curveForKey:privateOrPublicKey];
    GMEllipticCurveCrypto *crypto = [[GMEllipticCurveCrypto alloc] initWithCurve:curve];
    if ([privateOrPublicKey length] % 2) {
        crypto.publicKey = privateOrPublicKey;
    } else {
        crypto.privateKey = privateOrPublicKey;
    }
    return crypto;
}


+ (GMEllipticCurveCrypto*)cryptoForKeyBase64:(NSString *)privateOrPublicKey {
    return [self cryptoForKey:[[NSData alloc] initWithBase64EncodedString:privateOrPublicKey options:0]];
}

+ (id)cryptoForCurve:(GMEllipticCurve)curve {
    return [[self alloc] initWithCurve:curve];
}

- (id)initWithCurve:(GMEllipticCurve)curve {
    self = [super init];
    if (self) {
        _compressedPublicKey = YES;

        _bits = curve;
        _bytes = _bits / 8;
        _numDigits = _bytes / 8;
        
        switch (_bits) {
            case 128:
                _name = @"secp128r1";
                _curve_p = Curve_p_128;
                _curve_b = Curve_b_128;
                _curve_Gx = Curve_Gx_128;
                _curve_Gy = Curve_Gy_128;
                _curve_n = Curve_n_128;
                break;
            case 192:
                _name = @"secp192r1";
                _curve_p = Curve_p_192;
                _curve_b = Curve_b_192;
                _curve_Gx = Curve_Gx_192;
                _curve_Gy = Curve_Gy_192;
                _curve_n = Curve_n_192;
                break;
            case 256:
                _name = @"secp256r1";
                _curve_p = Curve_p_256;
                _curve_b = Curve_b_256;
                _curve_Gx = Curve_Gx_256;
                _curve_Gy = Curve_Gy_256;
                _curve_n = Curve_n_256;
                break;
            case 384:
                _name = @"secp384r1";
                _curve_p = Curve_p_384;
                _curve_b = Curve_b_384;
                _curve_Gx = Curve_Gx_384;
                _curve_Gy = Curve_Gy_384;
                _curve_n = Curve_n_384;
                break;
            default:
                NSLog(@"These are not the droids you are looking for.");
                return nil;
                break;
        }

    }
    return self;
}


- (BOOL)generateNewKeyPair {
    uint8_t l_public[_bytes + 1];
    uint8_t l_private[_bytes];
        
    BOOL success = ecc_make_key(l_public, l_private, _numDigits, _curve_p, _curve_n, _curve_Gx, _curve_Gy);
    
    _publicKey = [NSData dataWithBytes:l_public length:_bytes + 1];
    _privateKey = [NSData dataWithBytes:l_private length:_bytes];
    
    return success;
}


- (NSData*)sharedSecretForPublicKey: (NSData*)otherPublicKey {
    if (!_privateKey) {
        [NSException raise:@"Missing Key" format:@"Cannot create shared secret without a private key"];
    }
    
    // Prepare the private key
    uint8_t l_private[_bytes];
    if ([_privateKey length] != _bytes) {
        [NSException raise:@"Invalid Key" format:@"Private key %@ is invalid", _privateKey];
    }
    [_privateKey getBytes:&l_private length:[_privateKey length]];

    // Prepare the public key
    uint8_t l_other_public[_bytes + 1];
    if ([otherPublicKey length] != _bytes + 1) {
        [NSException raise:@"Invalid Key" format:@"Public key %@ is invalid", otherPublicKey];
    }
    [otherPublicKey getBytes:&l_other_public length:[otherPublicKey length]];

    // Create the secret
    uint8_t l_secret[_bytes];
    int success = ecdh_shared_secret(l_other_public, l_private, l_secret, _numDigits, _curve_p, _curve_b);

    if (!success) { return nil; }
    
    return [NSData dataWithBytes:l_secret length:_bytes];
}


- (NSData*)sharedSecretForPublicKeyBase64: (NSString*)otherPublicKeyBase64 {
    return [self sharedSecretForPublicKey:[[NSData alloc] initWithBase64EncodedString:otherPublicKeyBase64 options:0]];
}


- (NSData*)signatureForHash:(NSData *)hash {
    if (!_privateKey) {
        [NSException raise:@"Missing Key" format:@"Cannot sign a hash without a private key"];
    }

    // Prepare the private key
    uint8_t l_private[_bytes];
    if ([_privateKey length] != _bytes) {
        [NSException raise:@"Invalid Key" format:@"Private key %@ is invalid", _privateKey];
    }
    [_privateKey getBytes:&l_private length:[_privateKey length]];
    
    // Prepare the hash
    uint8_t l_hash[_bytes];
    if ([hash length] != _bytes) {
        [NSException raise:@"Invalid hash" format:@"Signing requires a hash the same length as the curve"];
    }
    [hash getBytes:&l_hash length:[hash length]];
    
    // Create the signature
    uint8_t l_signature[2 * _bytes];
    int success = ecdsa_sign(l_private, l_hash, l_signature, _numDigits, _curve_p, _curve_n, _curve_Gx, _curve_Gy);

    if (!success) { return nil; }
    
    return [NSData dataWithBytes:l_signature length:2 * _bytes];
}


- (BOOL)verifySignature:(NSData *)signature forHash:(NSData *)hash {
    if (!_publicKey) {
        [NSException raise:@"Missing Key" format:@"Cannot verify signature without a public key"];
    }

    // Prepare the signature
    uint8_t l_signature[2 * _bytes];
    if ([signature length] != 2 * _bytes) {
        [NSException raise:@"Invalid signature" format:@"Signature must be twice the length of its curve"];
    }
    [signature getBytes:&l_signature length:[signature length]];

    // Prepare the public key
    uint8_t l_public[_bytes + 1];
    if ([_publicKey length] != _bytes + 1) {
        [NSException raise:@"Invalid Key" format:@"Public key %@ is invalid", _publicKey];
    }
    [_publicKey getBytes:&l_public length:[_publicKey length]];

    // Prepare the hash
    uint8_t l_hash[_bytes];
    if ([hash length] != _bytes) {
        [NSException raise:@"Invalid hash" format:@"Verifying requires a hash the same length as the curve"];
    }
    [hash getBytes:&l_hash length:[hash length]];

    // Check the signature
    return ecdsa_verify(l_public, l_hash, l_signature, _numDigits, _curve_p, _curve_b, _curve_n, _curve_Gx, _curve_Gy);
}


- (int)hashLength {
    return _bytes;
}


- (int)sharedSecretLength {
    return _bytes;
}


- (int)signatureLength {
    return 2 * _bytes;
}


- (NSData*)publicKeyForPrivateKey: (NSData*)privateKey {

    // Prepare the private key
    uint8_t l_privateBytes[_bytes];
    if ([privateKey length] != _bytes) {
        [NSException raise:@"Invalid Key" format:@"Private key %@ is invalid", privateKey];
    }
    [privateKey getBytes:&l_privateBytes length:[privateKey length]];
    uint64_t l_private[_numDigits];
    ecc_bytes2native(l_private, l_privateBytes, _numDigits);

    // The (x, y) public point
    uint64_t l_publicX[_numDigits], l_publicY[_numDigits];
    EccPoint_mult(l_publicX, l_publicY, _curve_Gx, _curve_Gy, l_private, NULL, vli_numBits(l_private, _numDigits), _numDigits, _curve_p);

    // Now compress the point into our public key
    uint8_t l_public[_bytes + 1];
    ecc_native2bytes(l_public + 1, l_publicX, _numDigits);
    l_public[0] = 2 + (l_publicY[0] & 0x01);

    return [NSData dataWithBytes:l_public length:_bytes + 1];
}

- (NSData*)compressPublicKey: (NSData*)publicKey {

    NSInteger length = [publicKey length];

    if (length == 0) {
        return nil;
    }

    const uint8_t *bytes = [publicKey bytes];

    switch (bytes[0]) {

        // Already compressed
        case 0x02: case 0x03:
            if (length != (1 + _bytes)) {
                return nil;
            }

            return publicKey;

        // Compress!
        case 0x04: {
            if (length != (1 + 2 * _bytes)) {
                return nil;
            }

            // Get the (x, y) point from the public key
            uint64_t l_publicX[_numDigits], l_publicY[_numDigits];
            ecc_bytes2native(l_publicX, &bytes[1], _numDigits);
            ecc_bytes2native(l_publicY, &bytes[1 + _bytes], _numDigits);

            // And compress
            uint8_t l_public[_bytes + 1];
            ecc_native2bytes(l_public + 1, l_publicX, _numDigits);
            l_public[0] = 2 + (l_publicY[0] & 0x01);

            return [NSData dataWithBytes:l_public length:_bytes + 1];
        }
    }

    return nil;
}

- (NSData*)decompressPublicKey: (NSData*)publicKey {
    NSInteger length = [publicKey length];

    if (length == 0) {
        return nil;
    }

    const uint8_t *bytes = [publicKey bytes];

    switch (bytes[0]) {

        // Already uncompressed
        case 0x04:
            if (length != (1 + 2 * _bytes)) {
                return nil;
            }
            return publicKey;

        case 0x02: case 0x03: {
            if (length != (1 + _bytes)) {
                return nil;
            }

            // Decompress to get the (x, y) point
            uint64_t l_publicX[_numDigits], l_publicY[_numDigits];
            ecc_point_decompress(l_publicX, l_publicY, [_publicKey bytes], _numDigits, _curve_p, _curve_b);

            // Compose the public key (0x04 + x + y)
            uint8_t l_public[2 * _bytes + 1];
            l_public[0] = 0x04;
            ecc_native2bytes(l_public + 1, l_publicX, _numDigits);
            ecc_native2bytes(l_public + 1 + _bytes, l_publicY, _numDigits);

            return [NSData dataWithBytes:l_public length:2 * _bytes + 1];
        }
    }

    return nil;
}

- (NSString*)privateKeyBase64 {
    return [_privateKey base64EncodedStringWithOptions:0];
}


- (void)setPrivateKey: (NSData*)privateKey {
    int keyBits = [GMEllipticCurveCrypto curveForKey:privateKey];
    if (keyBits != _bits) {
        [NSException raise:@"Invalid Key" format:@"Private key %@ is %d bits; curve is %d bits", privateKey, keyBits, _bits];
    }

    NSData *checkPublicKey = [self publicKeyForPrivateKey:privateKey];
    if (_publicKey && ![_publicKey isEqual:checkPublicKey]) {
        [NSException raise:@"Key mismatch" format:@"Private key %@ does not match public key %@", privateKey, _publicKey];
    }
    
    _publicKey = checkPublicKey;
    _privateKey = privateKey;
}


- (void)setPrivateKeyBase64:(NSString *)privateKeyBase64 {
    [self setPrivateKey:[[NSData alloc] initWithBase64EncodedString:privateKeyBase64 options:0]];
}


- (NSString*)publicKeyBase64 {
    return [self.publicKey base64EncodedStringWithOptions:0];
}


- (NSData*)publicKey {
    if (_compressedPublicKey) {
        return _publicKey;
    }
    return [self decompressPublicKey:_publicKey];
}

- (void)setPublicKey: (NSData*)publicKey {
    int keyBits = [GMEllipticCurveCrypto curveForKey:publicKey];
    if (keyBits != _bits) {
        [NSException raise:@"Invalid Key" format:@"Public key %@ is %d bits; curve is %d bits", publicKey, keyBits, _bits];
    }

    const uint8_t *bytes = [publicKey bytes];
    BOOL compressedPublicKey = (bytes[0] != (uint8_t)0x04);

    // Ensure the key is compressed (we only store compressed keys internally)
    publicKey = [self compressPublicKey:publicKey];

    // If the private key has already been set, and it doesn't match, complain
    if (_privateKey && ![publicKey isEqual:_publicKey]) {
        [NSException raise:@"Key mismatch" format:@"Private key %@ does not match public key %@", _privateKey, publicKey];
    }

    _compressedPublicKey = compressedPublicKey;
    _publicKey = publicKey;
}


- (void)setPublicKeyBase64:(NSString *)publicKeyBase64 {
    [self setPublicKey:[[NSData alloc] initWithBase64EncodedString:publicKeyBase64 options:0]];
}


- (NSString*)description {
    return [NSString stringWithFormat:@"<GMEllipticCurveCrypto algorithm=%@ publicKey=%@ privateKey=%@>", _name, self.publicKeyBase64, self.privateKeyBase64];
}


@end
