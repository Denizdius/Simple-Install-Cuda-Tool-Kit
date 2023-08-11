#!/bin/bash

# Check for Ubuntu 22.04 LTS
UBUNTU_VERSION=$(lsb_release -r -s)
if [ "$UBUNTU_VERSION" != "22.04" ]; then
    echo "This script is intended for Ubuntu 22.04 LTS. Detected Ubuntu version: $UBUNTU_VERSION"
    exit 1
fi


# Check for NVIDIA drivers
if ! command -v nvidia-smi &> /dev/null; then
    echo "NVIDIA drivers are not installed. Installing NVIDIA drivers..."
    sudo apt update
    sudo apt search nvidia-driver

    read -p "You can edit nvidia driver version file before installation, Do you want to proceed with installing NVIDIA drivers? (y/n): " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        sudo apt install nvidia-driver-535 nvidia-dkms-535  #You can edit the version of driver
        echo "NVIDIA drivers have been installed. Please reboot your system before proceeding."
    else
        echo "NVIDIA drivers were not installed. Exiting..."
        exit 1
    fi
fi

# Check for CUDA-compatible GPU
GPU_COUNT=$(nvidia-smi --query-gpu=count --format=csv,noheader)
if [ "$GPU_COUNT" -eq 0 ]; then
    echo "No compatible NVIDIA GPU found. Exiting."
    exit 1
fi

# Check for GCC
if ! command -v gcc &> /dev/null; then
    echo "GCC is not installed. Please install it before proceeding."
    exit 1
fi

# Set the CUDA version and runfile
CUDA_VERSION="12.2.1"
CUDA_RUNFILE="cuda_${CUDA_VERSION}_535.86.10_linux.run"  # Customize this for your desired CUDA version

# Download CUDA runfile
wget https://developer.download.nvidia.com/compute/cuda/${CUDA_VERSION}/local_installers/${CUDA_RUNFILE}

# Make the runfile executable
chmod +x ${CUDA_RUNFILE}

# Notify the user
echo "Please do NOT choose to install the NVIDIA driver when running the CUDA installer."
echo "Ensure that you've already installed the NVIDIA driver separately."
echo "If you want to install a different CUDA version, make sure to change the CUDA_VERSION and CUDA_RUNFILE variables."

# Run the CUDA installer
sudo ./${CUDA_RUNFILE}

# Extract the two-digit CUDA version (e.g., 12.2) for PATH addition
TWO_DIGIT_CUDA_VERSION=$(echo $CUDA_VERSION | cut -d. -f1-2)

# Add CUDA to PATH and configure environment variables
echo "export PATH=/usr/local/cuda-$TWO_DIGIT_CUDA_VERSION/bin:\$PATH" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=/usr/local/cuda-$TWO_DIGIT_CUDA_VERSION/lib64:\$LD_LIBRARY_PATH" >> ~/.bashrc
source ~/.bashrc

# Verify installation
nvcc --version

