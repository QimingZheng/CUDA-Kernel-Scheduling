# CUDA Kernel Scheduling

## Supports

1. CUDA kernel suspend
2. CUDA kernel resume
3. Schedule CUDA kernel

## 方案

| 方案 | 描述 | 潜在问题 |
| -- | -- | -- |
| cudaResetDevice | fork一个pthread，然后把要起的cuda kernel放在这个pthread里面run，pthread和parent process通信以确定是否中断执行，通过cudaResetDevice进行中断 | cudaResetDevice是否有效；cudaResetDevice是否会destroy掉master Process的资源； |
| PTX | source to source的代码改动，通过添加__trap()和__brkpt()实现kernel中断 | 需要软件上的支持，kernel需要频繁的读CPU memory的flag |
| cudastream priority | 额外构造一个新的高优先级的cuda stream，在新的cuda stream里面launch一个idle的cuda kernel达到抢断的目的 | idle kernel怎么写；idle kernel必须很小（指的是block数少，kernel执行工作轻量级，带来的overhead才能小），但是小idle kernel会不会让正在running的kernel有机会得到资源跑，从而达不到抢断的目标？ |


## Practise

plan1合理的做法是在不同的pthread中launch kernel，pthread之间reset device不会相互影响，但是pthread中的reset会对master process产生影响。

plan1需要解决的其他问题：
1. 如何restore？
2. 如何把结果传回？