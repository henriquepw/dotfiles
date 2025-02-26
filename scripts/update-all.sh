#!/bin/bash

echo "Atualizando pacotes APT..."
sudo apt update && sudo apt upgrade -y

echo "Atualizando pacotes Snap..."
sudo snap refresh

echo "Atualizando pacotes Flatpak..."
flatpak update -y

echo "Atualizando pacotes Homebrew..."
brew update && brew upgrade

echo "Atualização completa!"
