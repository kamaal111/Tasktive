#!/bin/sh

#  bootstrap.sh
#  Tasktive
#
#  Created by Kamaal M Farah on 14/08/2022.
#  

time {
    # Install node modules
    echo "Installing node modules"
    yarn

    # Install homebrew packages
    echo "Installing homebrew packages"
    brew bundle

    # Get or update all submodules
    echo "Cloning all submodules"
    git submodule update --init --recursive

    # Create tokens file
    echo "Creating tokens file"
    yarn generate-tokens
}
