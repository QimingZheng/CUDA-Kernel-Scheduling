#include <pthread.h>
#include <stdio.h>
#include <helper_cuda.h>

const int N = 1 << 20;

__global__ void kernel(float *x, int n)
{
    int tid = threadIdx.x + blockIdx.x * blockDim.x;
    // while(true);
    for (int i = tid; i < n; i += blockDim.x * gridDim.x) {
        x[i] = sqrt(pow(3.14159,i));
    }
}

struct args{
    float *data;
    int id;
};

void *launch_kernel(void *arg)
{
    float *data;
    cudaMalloc(&data, N * sizeof(float));
    cudaStream_t stream;
    cudaStreamCreate(&stream);
    // kernel<<<1, 1, 64, stream>>>(((struct args*)arg)->data, N);
    kernel<<<1, 1, 64, stream>>>(data, N);
    if (((struct args*)arg)->id % 2) {
        checkCudaErrors(cudaDeviceReset());
        return NULL;
    } else {
        checkCudaErrors(cudaStreamSynchronize(stream));
        checkCudaErrors(cudaMemcpy(((struct args*)arg)->data, data, N*sizeof(float), cudaMemcpyDeviceToDevice));
        return NULL;
    }
}

int main()
{
    const int num_threads = 8;

    pthread_t threads[num_threads];
    float *data[num_threads];
    for (int i = 0 ; i < num_threads; i++) {
        checkCudaErrors(cudaMalloc(&data[i], N * sizeof(float)));
    }

    for (int i = 0; i < num_threads; i++) {
        struct args *arg = new args;
        arg->data = data[i];
        arg->id = i;
        if (pthread_create(&threads[i], NULL, launch_kernel, arg)) {
            fprintf(stderr, "Error creating thread\n");
            return 1;
        }
    }

    for (int i = 0; i < num_threads; i++) {
        if(pthread_join(threads[i], NULL)) {
            fprintf(stderr, "Error joining thread\n");
            return 2;
        }
    }

    // cudaDeviceReset();

    return 0;
}
