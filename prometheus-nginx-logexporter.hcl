listen {
  port = 4040
  address = "172.31.89.251"
}

consul {
  enable = false
}

namespace "nginx" {
  source = {
    files = [
      "/var/log/nginx/access.log"
    ]
  }

  format = "$remote_addr - $remote_user [$time_local] \"$request\" $status $body_bytes_sent \"$http_referer\" \"$http_user_agent\" \"$http_x_forwarded_for\""

  labels {
    app = "default"
  }
}