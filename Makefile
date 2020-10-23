CC=/usr/local/cuda/bin/nvcc
CC_INCLUDE_PATH=-I/usr/local/cuda/samples/common/inc/

all: kernel_preemption plan1

kernel_preemption: kernel_preemption.cu
	${CC} ${CC_INCLUDE_PATH} kernel_preemption.cu -o kernel_preemption

plan1: plan1.cu
	${CC} ${CC_INCLUDE_PATH} plan1.cu -o plan1

clean:
	rm kernel_preemption plan1