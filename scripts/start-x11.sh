until x11vnc -display :99 -rfbport 80 -forever; do
    echo "x11vnc crashed with exit code $?.  Respawning.." >&2
    sleep 1
done