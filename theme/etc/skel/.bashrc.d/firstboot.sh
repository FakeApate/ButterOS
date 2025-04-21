SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [[ ! $SCRIPT_DIR == $HOME/.bashrc.d/ ]]; then
    echo "not user home"!
    exit 1
fi

ZSH="${ZSH:-$HOME/.oh-my-zsh}"
P10K_URL=https://github.com/romkatv/powerlevel10k.git
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
P10K_CHECK="${P10K_DIR}/powerlevel10k.zsh-theme"
OHMYZSH_URL=https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
OHMYZSH_CHECK="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/oh-my-zsh.sh}"
GITHUB_USERNAME=FakeApate


if [[ ! -d "$ZSH" ]]; then
    sh -c "$(curl -fsSL $OHMYZSH_URL)" "" --unattended --keep-zshrc
fi

if [ ! -f "${P10K_CHECK}" ] && [ -f "${OHMYZSH_CHECK}" ]; then
    git clone --depth=1 "${P10K_URL}" "${P10K_DIR}" || exit 1
fi

if ! command -v "chezmoi" > /dev/null 2>&1; then
    sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME --force
fi

shred -u "${0}"
