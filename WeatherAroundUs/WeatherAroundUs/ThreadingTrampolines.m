//
//  ThreadingTrampolines.m
//  SwiftNonStandardLibrary
//
//  Created by User on 6/26/14.
//  Copyright (c) 2014 User. All rights reserved.
//

#import "ThreadingTrampolines.h"


//#if __has_feature(objc_arc)
//#error ARC cannot be enabled for this file
//#endif

void oss_pthread_cleanupKey(void *value) {
    if(value != NULL) {
        CFBridgingRelease(value);
        //NOTE: must be tested! Is this sufficient to release any object or will we have problems here?
    }
}


pthread_key_t oss_pthread_createKey() {
    pthread_key_t key;
    if(pthread_key_create(&key, &oss_pthread_cleanupKey) != 0) {
        NSLog(@"Failed to allocate a pthread key slot for thread-local storage");
        abort();
    }
    return key;
}

void oss_dispatch_cleanup_queue(void * value)
{
    if(value != NULL) {
        CFBridgingRelease(value);
    }
}

void oss_dispatch_set_finalizer_f(dispatch_queue_t queue)
{
    dispatch_set_finalizer_f(queue, &oss_dispatch_cleanup_queue);
}


void oss_dispatch_queue_cleanup_specific(void *value)
{
    if(value != NULL) {
        CFBridgingRelease(value);
    }
}

void oss_dispatch_queue_set_specific(dispatch_queue_t queue, const void *key, void *obj)
{
    dispatch_queue_set_specific(queue, key, obj, &oss_dispatch_queue_cleanup_specific);
}


id oss_void_pointer_to_object_unretained(void *ptr)
{
    return (__bridge id)ptr;
}