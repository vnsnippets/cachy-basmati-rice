sudo pacman -S docker docker-compose
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
sudo systemctl enable --now docker.service