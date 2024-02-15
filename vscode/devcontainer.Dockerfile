FROM opensuse/tumbleweed

# Install basic tools & Create the user
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN zypper -n up && zypper -n in sudo shadow gawk git stow zip zsh openssh-clients eza \
  && groupadd --gid $USER_GID $USERNAME \
  && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  && chsh -s $(which zsh) $USERNAME

# Install additional packages
RUN sudo zypper -n in go

# Switch to non-root user
USER $USERNAME
