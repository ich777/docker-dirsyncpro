until websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem 80 localhost:5900; do
    echo "noVNC server crashed with exit code $?.  Respawning.." >&2
    sleep 1
done