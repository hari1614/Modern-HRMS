FROM frappe/bench:latest

# Copy your script into the Docker container
COPY init.sh /workspace/init.sh

# Set executable permissions INSIDE the container
RUN chmod +x /workspace/init.sh

# Run the script
CMD ["bash", "/workspace/init.sh"]
