FROM hardandheavy/transformers-rocm:2.4.0

EXPOSE 80

RUN git clone https://github.com/oobabooga/text-generation-webui.git /app 

WORKDIR /app
RUN pip install -r requirements_cpu_only.txt

ENV LLAMA_CPP_PYTHON_VERSION=0.3.1
ENV DAMDGPU_TARGETS=gfx900;gfx906;gfx908;gfx90a;gfx1030;gfx1100;gfx1101;gfx940;gfx941;gfx942
RUN CMAKE_ARGS="-DGGML_HIPBLAS=on -DCMAKE_C_COMPILER=/opt/rocm/llvm/bin/clang -DCMAKE_CXX_COMPILER=/opt/rocm/llvm/bin/clang++ -DAMDGPU_TARGETS=${DAMDGPU_TARGETS}" pip install llama-cpp-python==${LLAMA_CPP_PYTHON_VERSION}

CMD python server.py \
    --listen \
    --listen-port=80
