FROM ubuntu:trusty

# install unix dependencies
RUN apt-get update && apt-get install wget unzip cron -y

# install aws cli dependency
RUN wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
RUN mv awscli-exe-linux-x86_64.zip awscliv2.zip
RUN unzip awscliv2.zip
RUN ./aws/install
RUN rm awscliv2.zip

# add our crontask
COPY ./crontask /etc/cron.d/crontask
RUN chmod 0644 /etc/cron.d/crontask
RUN crontab /etc/cron.d/crontask

# add our backup script ran by the crontask
COPY ./backup.sh /root/backup.sh

# use custom "crond which prepare a container.env file for crontask"
COPY ./crond.sh /root/crond.sh

# run this `crond` (running cron in foreground)
CMD /root/crond.sh
