#!/usr/bin/fish

function error --argument-names text reason
    zenity --error --text="$text.
Failure reason: $reason."
    exit 1
end

function info --argument-names text
    zenity --info --text=$text
    exit 1
end

function question --argument-names text
    zenity --question --text=$text
end

test (uname) = Linux ||
    error "This installer is intended to be used on Linux" "current operating system is $(uname)"

set download_url_prefix https://raw.githubusercontent.com/EmilyGraceSeville7cf/tinyscheme-turtle/main
set download_scripts turtle turtle-theme
set download_directory (mktemp --directory)
set installation_directory ~/.config/GIMP

test -d $installation_directory ||
    error "GIMP seems to be not properly installed" "no $installation_directory directory found"

for script in $download_scripts
    https $download_url_prefix/$script.scm >$download_directory/$script.scm
end

set gimp_versions (ls --format=single-column --hide-control-chars $installation_directory)
set gimp_version_count (count $gimp_versions)
set gimp_selected_version

test $gimp_version_count -gt 1 && begin
    set gimp_selected_version (zenity --list \
        --title="Choose GIMP version you want install Turtle to" \
        --column="Version" \
        $gimp_versions)

    test $status -ne 0 &&
        info "Installation has been cancelled."

    set gimp_scripts_directory $installation_directory/$gimp_selected_version/scripts

    test -d $gimp_scripts_directory ||
        error "GIMP $gimp_selected_version seems to broken" "no $gimp_scripts_directory directory found"

    for script in $download_scripts
        set script_path $gimp_scripts_directory/$script.scm
        test -f $script_path && question "File $script_path already exists, do you want override it?"

        test $status -eq 0 && mv --force $download_directory/$script.scm $script_path
    end
end

zenity --info --text="Installation has been completed."
