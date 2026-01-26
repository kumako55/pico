FROM traffmonetizer/cli_v2

# Use TOKEN environment variable for tmcli
CMD ["tmcli", "start", "accept", "--token", "${TOKEN}"]
