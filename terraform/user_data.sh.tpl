#!/bin/bash
set -euo pipefail

dnf update -y
dnf install -y amazon-cloudwatch-agent

cat >/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<EOF
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "${log_group_system}",
            "log_stream_name": "{instance_id}/messages",
            "retention_in_days": ${log_retention_days}
          },
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name": "${log_group_cloud_init}",
            "log_stream_name": "{instance_id}/cloud-init",
            "retention_in_days": ${log_retention_days}
          }
        ]
      }
    }
  }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s

systemctl enable amazon-cloudwatch-agent
systemctl restart amazon-cloudwatch-agent
