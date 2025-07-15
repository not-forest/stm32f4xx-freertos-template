#include "FreeRTOS.h"
#include <task.h>

/* Static allocation support */
static StaticTask_t xIdleTaskTCB;
static StackType_t xIdleStack[configMINIMAL_STACK_SIZE];
void vApplicationGetIdleTaskMemory( StaticTask_t **ppxIdleTaskTCBBuffer,
                                    StackType_t **ppxIdleTaskStackBuffer,
                                    uint32_t *pulIdleTaskStackSize )
{
    *ppxIdleTaskTCBBuffer = &xIdleTaskTCB;
    *ppxIdleTaskStackBuffer = xIdleStack;
    *pulIdleTaskStackSize = configMINIMAL_STACK_SIZE;
}

static StaticTask_t xTimerTaskTCB;
static StackType_t xTimerStack[configTIMER_TASK_STACK_DEPTH];
void vApplicationGetTimerTaskMemory( StaticTask_t **ppxTimerTaskTCBBuffer,
                                     StackType_t **ppxTimerTaskStackBuffer,
                                     uint32_t *pulTimerTaskStackSize )
{
    *ppxTimerTaskTCBBuffer = &xTimerTaskTCB;
    *ppxTimerTaskStackBuffer = xTimerStack;
    *pulTimerTaskStackSize = configTIMER_TASK_STACK_DEPTH;
}

/* Hook functions */
void vApplicationIdleHook(void)
{
    /* Optional user code for idle hook */
}

void vApplicationTickHook(void)
{
    /* Optional user code for tick hook */
}

void vApplicationStackOverflowHook(TaskHandle_t xTask, char *pcTaskName)
{
    /* Handle stack overflow, maybe halt or log */
    (void) xTask;
    (void) pcTaskName;
    taskDISABLE_INTERRUPTS();
    for( ;; );
}

void vApplicationMallocFailedHook(void)
{
    /* Handle malloc failure */
    taskDISABLE_INTERRUPTS();
    for( ;; );
}