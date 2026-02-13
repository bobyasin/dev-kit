FROM rabbitmq:3.12-management

# Download and install the delayed message exchange plugin
RUN apt-get update && apt-get install -y wget && \
    wget https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases/download/3.12.0/rabbitmq_delayed_message_exchange-3.12.0.ez -O /opt/rabbitmq/plugins/rabbitmq_delayed_message_exchange-3.12.0.ez && \
    apt-get remove -y wget && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Enable the delayed message exchange plugin
RUN rabbitmq-plugins enable --offline rabbitmq_delayed_message_exchange

# Copy custom configuration if needed
COPY definitions.json /etc/rabbitmq/definitions.json