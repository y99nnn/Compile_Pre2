    .arch armv7-a         @ 指定目标体系结构为ARMv7-A

.data                  @ 数据�?
.section .rodata
_str0:                 
    .ascii "Please input the number\n\0 "   
_str1:
    .ascii "%d\0"     
_str2:
    .ascii "factorial(%d) is %d\n\0"       

.text                  @ 代码�?
.global factorial     

factorial:

    str lr, [sp, #-4]!   @ 保存链接寄存器lr到栈上，使用预增量模式，sp = sp - 4,push lr
    str r0, [sp, #-4]!    @ 将n（r0）保存到栈上，预增量模式

    cmp r0, #0           @ 比较n（r0）与0
    bne .L2              @ 如果n != 0，跳转到.L2标签

    mov r0, #1           @ 如果n == 0，则返回1
    b .L3                @ 跳转�?.L3标签

.L2:
    sub r0, r0, #1       @ r0 = n-1
    bl factorial         @ 递归调用factorial函数
    ldr r1, [sp]         @ 将n-1加载到r1
    mul r0, r0, r1       @ 计算n * factorial(n-1)

.L3:
    add sp, sp, #4       @ 恢复栈指针，sp = sp + 4
    ldr lr, [sp], #4     @ 恢复链接寄存器lr，后增量模式
    bx lr                @ 返回，恢复栈指针、帧指针和程序计数器

.global main           @ 定义main函数为全局可见

main:
    str lr, [sp,#-4]!    @ 保存链接寄存器lr到栈�?
    sub sp, sp, #4        @ 分配4字节的栈空间

    ldr r0, _bridge      @ 加载字符�? "Please input the number: " 的地址到r0
    bl printf             @ 调用printf打印提示信息

    mov r1, sp            @ 将栈指针sp的地址存储在r1�?
    ldr r0, _bridge+4      @ 加载字符�? "%d\0" 的地址到r0�?
    bl __isoc99_scanf     @ 调用scanf读取用户输入的整数，结果存储在r0�?

    ldr r0, [sp]          @ 将用户输入的整数n加载到r0

    bl factorial          @ 调用factorial函数计算阶乘

    mov r2, r0            @ 将计算结�?(factorial(n))存储在r2�?
    ldr r1, [sp]          @ 将用户输入的整数n加载到r1�?
    ldr r0, _bridge+8      @ 加载字符�? _str3的地址到r0
    bl printf             @ 调用printf打印阶乘结果

    mov r0, #0             @return 0
    add sp, sp, #4        @ 释放栈空�?
    ldr lr, [sp], #4      @ 恢复链接寄存器lr
    bx lr                 @ 返回

_bridge:
    .word _str0  @"Please input the number:\n "
    .word _str1  @"%d\0"
    .word _str2  @"factorial(%d) is %d\n\0" 

.section .note.GNU-stack, "", %progbits  
