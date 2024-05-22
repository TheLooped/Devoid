#!/bin/bash

# Prompt for the device
read -p "Enter the device (e.g., /dev/sda): " device

# Get the free space information
free_space=$(sudo sfdisk -F "$device" | awk '/Unpartitioned space/ {print $4}')


echo "Free space: $free_space"

# Prompt for partition sizes
read -p "Enter the size for EFI partition (in MiB): " efi_size
read -p "Enter the size for root partition (in GiB): " root_size
read -p "Do you want a swap partition? (y/n) " want_swap
if [[ "$want_swap" == "y" ]]; then
    read -p "Enter the size for swap partition (in GiB): " swap_size
fi
read -p "Do you want a home partition? (y/n) " want_home
if [[ "$want_home" == "y" ]]; then
    read -p "Enter the size for home partition (in GiB): " home_size
fi

# Calculate the start and end sectors for each partition
start_sector=2048  # Start from 1 MiB
efi_end_sector=$((start_sector + efi_size * 2048))
root_start_sector=$efi_end_sector
root_end_sector=$((root_start_sector + root_size * 2097152))
if [[ "$want_swap" == "y" ]]; then
    swap_start_sector=$root_end_sector
    swap_end_sector=$((swap_start_sector + swap_size * 2097152))
    home_start_sector=$swap_end_sector
else
    home_start_sector=$root_end_sector
fi

# Create the partitions
echo "$start_sector,$((efi_end_sector - start_sector)),ef00" | sfdisk --append "$device"
efi_part_num=$(sfdisk -l "$device" | awk '/EFI/ {print $1}' | cut -d'=' -f2)
echo "$root_start_sector,$((root_end_sector - root_start_sector)),L" | sfdisk --append "$device"
root_part_num=$(sfdisk -l "$device" | awk '/Linux/ {print $1}' | cut -d'=' -f2 | tail -n1)
if [[ "$want_swap" == "y" ]]; then
    echo "$swap_start_sector,$((swap_end_sector - swap_start_sector)),S" | sfdisk --append "$device"
    swap_part_num=$(sfdisk -l "$device" | awk '/swap/ {print $1}' | cut -d'=' -f2 | tail -n1)
fi
if [[ "$want_home" == "y" ]]; then
    echo "$home_start_sector,+" | sfdisk --append "$device"
    home_part_num=$(sfdisk -l "$device" | awk '/Linux/ {print $1}' | cut -d'=' -f2 | tail -n1)
fi

echo "Created partitions:"
echo "EFI partition: $device$efi_part_num"
echo "Root partition: $device$root_part_num"
if [[ "$want_swap" == "y" ]]; then
    echo "Swap partition: $device$swap_part_num"
fi
if [[ "$want_home" == "y" ]]; then
    echo "Home partition: $device$home_part_num"
fi
