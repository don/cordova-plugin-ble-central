#!/bin/sh

#  Script.sh
#  SigMeshOC
#
#  Created by 梁家誌 on 2019/12/13.
#  Copyright © 2019 梁家誌. All rights reserved.


#注意：脚本目录和xxxx.xcodeproj要在同一个目录，如果放到其他目录，请自行修改脚本。
#注意：当前脚本默认release基础版本的库，如果要release源码扩展版本的库，需要添加Extensions文件及其文件，target_Name=TelinkSigMeshLib修改为target_Name=TelinkSigMeshLibExtensions。
#要build的target名
target_Name=TelinkSigMeshLib
echo "target_Name=${target_Name}"

#工程名
project_name=TelinkSigMeshLib
echo "project_name=${project_name}"

#打包模式 Debug/Release 默认是Release
development_mode=Release


#当前脚本文件所在的路径 $(pwd)
SCRIPT_DIR=$(pwd)
echo "======脚本路径=${SCRIPT_DIR}======"

#工程路径
#PROJECT_DIR=${SCRIPT_DIR} 和下面写法也样
PROJECT_DIR=$SCRIPT_DIR
echo "======工程路径=${PROJECT_DIR}======"

#build之后的文件夹路径
build_DIR=$SCRIPT_DIR/Build
echo "======Build路径=${build_DIR}======"

#真机build生成的.framework 文件路径
DEVICE_DIR_D=${build_DIR}/${development_mode}-iphoneos
DEVICE_DIR=${build_DIR}/${development_mode}-iphoneos/${project_name}.framework

#模拟器build生成的.framework 文件路径
SIMULATOR_DIR_D=${build_DIR}/${development_mode}-iphonesimulator
SIMULATOR_DIR=${build_DIR}/${development_mode}-iphonesimulator/${project_name}.framework

#真机build生成的sdk文件路径
DEVICE_DIR_A=${build_DIR}/${development_mode}-iphoneos/${project_name}.framework/${project_name}
echo "======真机.framework路径=${DEVICE_DIR_A}======"

#模拟器build生成的sdk文件路径
SIMULATOR_DIR_A=${build_DIR}/${development_mode}-iphonesimulator/${project_name}.framework/${project_name}
echo "======模拟器.framework路径=${SIMULATOR_DIR_A}======"



#目标文件夹路径（也就SDK的文件：真机.framework文件 和 模拟器.framework文件）
INSTALL_DIR=${build_DIR}/Products/${project_name}
echo "======SDK的文件夹路径=${INSTALL_DIR}======"

#真机 sdk Headers 路径
DEVICE_DIR_HEADER=${build_DIR}/${development_mode}-iphoneos/${project_name}.framework/Headers
echo "======真机sdk Headers路径=${DEVICE_DIR_HEADER}======"

#模拟器 sdk Headers 路径
SIMULATOR_DIR_HEADER=${build_DIR}/${development_mode}-iphonesimulator/${project_name}.framework/Headers
echo "======模拟器sdk Headers路径=${SIMULATOR_DIR_HEADER}======"


#判断build文件夹是否存在，存在则删除
#rm -rf 命令的功能:删除一个目录中的一个或多个文件或目录
if [ -d "${build_DIR}" ]
then
rm -rf "${build_DIR}"
fi


#判断目标文件夹是否存在，存在则删除该文件夹
if [ -d "${INSTALL_DIR}" ]
then
rm -rf "${INSTALL_DIR}"
fi


#创建目标文件夹
mkdir -p "${INSTALL_DIR}"
mkdir -p "${DEVICE_DIR_HEADER}"
mkdir -p "${SIMULATOR_DIR_HEADER}"



echo "======盒子已经准备好了，开始生产.a 并合成装到盒子里吧======"

#build之前clean一下
#xcodebuild -target ${target_Name} -configuration ${development_mode} -sdk iphonesimulator clean

#xcodebuild -target ${target_Name} -configuration ${development_mode} -sdk iphoneos clean

#模拟器build
xcodebuild -target ${target_Name} -configuration ${development_mode} -sdk iphonesimulator

#真机build
xcodebuild -target ${target_Name} -configuration ${development_mode} -sdk iphoneos


cp -R "${DEVICE_DIR_D}" "${INSTALL_DIR}"
cp -R "${SIMULATOR_DIR_D}" "${INSTALL_DIR}"
echo "======copy framework 结束======"


# -f 判断文件是否存在
if [ -f "${DEVICE_DIR_A}" ]
then
echo "======验证真机包是否成功======"
lipo -info "${DEVICE_DIR_A}"
fi

# -f 判断文件是否存在
if [ -f "${SIMULATOR_DIR_A}" ]
then
echo "======验证模拟器包是否成功======"
lipo -info "${SIMULATOR_DIR_A}"
fi

#打开目标文件夹
open "${INSTALL_DIR}"
