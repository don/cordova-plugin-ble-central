/********************************************************************************************************
 * @file     EventBus.java 
 *
 * @brief    for TLSR chips
 *
 * @author	 telink
 * @date     Sep. 30, 2010
 *
 * @par      Copyright (c) 2010, Telink Semiconductor (Shanghai) Co., Ltd.
 *           All rights reserved.
 *           
 *			 The information contained herein is confidential and proprietary property of Telink 
 * 		     Semiconductor (Shanghai) Co., Ltd. and is available under the terms 
 *			 of Commercial License Agreement between Telink Semiconductor (Shanghai) 
 *			 Co., Ltd. and the licensee in separate contract or the terms described here-in. 
 *           This heading MUST NOT be removed from this file.
 *
 * 			 Licensees are granted free, non-transferable use of the information in this 
 *			 file under Mutual Non-Disclosure Agreement. NO WARRENTY of ANY KIND is provided. 
 *           
 *******************************************************************************************************/

package com.telink.ble.mesh.foundation;

import android.os.Handler;
import android.os.Looper;


import com.telink.ble.mesh.util.MeshLogger;

import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

public class EventBus<T> {

    private static final int CPU_COUNT = Runtime.getRuntime().availableProcessors();
    private static final int CORE_POOL_SIZE = CPU_COUNT + 1;
    private static final int MAXIMUM_POOL_SIZE = CPU_COUNT * 2 + 1;
    private static final int KEEP_ALIVE = 1;
    private static final BlockingQueue<Runnable> sPoolWorkQueue =
            new LinkedBlockingQueue<>(128);
    private static final ThreadFactory sThreadFactory = new DefaultThreadFactory();

    private static final ExecutorService EXECUTOR_SERVICE = new ThreadPoolExecutor(CORE_POOL_SIZE, MAXIMUM_POOL_SIZE, KEEP_ALIVE,
            TimeUnit.SECONDS, sPoolWorkQueue, sThreadFactory); //Executors.newCachedThreadPool(new DefaultThreadFactory());

    protected final Map<T, List<EventListener<T>>> mEventListeners = new ConcurrentHashMap<>();
    protected final Queue<Event<T>> mEventQueue = new ConcurrentLinkedQueue<>();
    protected final Handler mCurrentThreadHandler = new Handler(Looper.myLooper());
    protected final Handler mMainThreadHandler = new Handler(Looper.getMainLooper());
    private final Object mLock = new Object();
    protected boolean processing = false;
    private final Runnable task = new Runnable() {
        @Override
        public void run() {
            processEvent();
        }
    };

    public void addEventListener(T eventType, EventListener<T> listener) {

        synchronized (this.mEventListeners) {
            List<EventListener<T>> listeners;

            if (this.mEventListeners.containsKey(eventType)) {
                listeners = this.mEventListeners.get(eventType);
            } else {
                listeners = new CopyOnWriteArrayList<>();
                this.mEventListeners.put(eventType, listeners);
            }

            if (!listeners.contains(listener)) {
                listeners.add(listener);
            }
        }
    }

    public void removeEventListener(EventListener<T> listener) {
        synchronized (this.mEventListeners) {
            for (T eventType : this.mEventListeners.keySet()) {
                this.removeEventListener(eventType, listener);
            }
        }
    }

    public void removeEventListener(T eventType, EventListener<T> listener) {
        synchronized (this.mEventListeners) {
            if (this.mEventListeners.containsKey(eventType)) {
                List<EventListener<T>> listeners = this.mEventListeners.get(eventType);
                listeners.remove(listener);
            }
        }
    }

    public void removeEventListeners() {
        synchronized (this.mEventListeners) {
            for (T eventType : this.mEventListeners.keySet()) {
                List<EventListener<T>> listeners = this.mEventListeners.get(eventType);
                listeners.clear();
                this.mEventListeners.remove(eventType);
            }
        }
    }

    public void dispatchEvent(final Event<T> event) {
//        MeshLogger.log("event looper : " + event.getThreadMode());

        this.mEventQueue.add(event);

        MeshLogger.log("post event : " + event.getType() + "--" + event.getClass().getSimpleName());

        synchronized (this.mLock) {
            if (!this.processing)
                this.processOnThread();
        }
    }

    private void processOnThread() {

        final Event<T> event;

        synchronized (mEventQueue) {
            event = this.mEventQueue.peek();
            if (event == null)
                return;
        }

        switch (event.getThreadMode()) {
            case Background:
                EXECUTOR_SERVICE.execute(task);
                break;
            case Main:
                mMainThreadHandler.post(task);
                break;
            case Default:
                mCurrentThreadHandler.post(task);
                break;

        }
    }

    private void processEvent() {
//        MeshLogger.log("process on thread : " + Thread.currentThread().getName());

        final Event<T> event;

        synchronized (mEventQueue) {
            event = mEventQueue.poll();
            if (event == null)
                return;
        }

//        MeshLogger.log("process event : " + event.getType() + "--" + event.getClass().getName());

        T eventType = event.getType();
        List<EventListener<T>> listeners = null;

        synchronized (this.mEventListeners) {
            if (this.mEventListeners.containsKey(eventType)) {
                listeners = this.mEventListeners.get(eventType);
            }
        }

        if (listeners != null && !listeners.isEmpty()) {
            synchronized (this.mLock) {
                this.processing = true;
            }

            for (EventListener<T> listener : listeners) {
                if (listener != null)
                    listener.performed(event);
            }
        }

        this.processEventCompleted();
    }

    private void processEventCompleted() {
        synchronized (this.mLock) {
            this.processing = false;
        }

        if (!this.mEventQueue.isEmpty())
            this.processOnThread();
    }

    private static class DefaultThreadFactory implements ThreadFactory {
        private static final AtomicInteger POOL_NUMBER = new AtomicInteger(1);
        private final AtomicInteger threadNumber = new AtomicInteger(1);
        private final ThreadGroup group;
        private final String namePrefix;

        DefaultThreadFactory() {
            SecurityManager s = System.getSecurityManager();
            group = (s != null) ? s.getThreadGroup() :
                    Thread.currentThread().getThreadGroup();
            namePrefix = "pool-" +
                    POOL_NUMBER.getAndIncrement() +
                    "-thread-";
        }

        @Override
        public Thread newThread(final Runnable r) {

            Runnable run = new Runnable() {
                @Override
                public void run() {
                    android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_BACKGROUND);
                    r.run();
                }
            };

            Thread thread = new Thread(group, run,
                    namePrefix + threadNumber.getAndIncrement(),
                    0);
            if (thread.isDaemon())
                thread.setDaemon(false);
            if (thread.getPriority() != Thread.NORM_PRIORITY)
                thread.setPriority(Thread.NORM_PRIORITY);

            return thread;
        }
    }
}
