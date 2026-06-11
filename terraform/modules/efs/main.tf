resource "aws_efs_file_system" "wordpress" {
  creation_token   = "${var.name_prefix}-wp-content"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = false # Academy puede tener limitaciones con KMS

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-efs-wp-content"
  })
}

# Mount target en cada subred privada (una por AZ)
resource "aws_efs_mount_target" "this" {
  count = length(var.private_subnet_ids)

  file_system_id  = aws_efs_file_system.wordpress.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [var.efs_sg_id]
}

# Access Point para wp-content con permisos correctos para el proceso de Apache/WordPress
resource "aws_efs_access_point" "wp_content" {
  file_system_id = aws_efs_file_system.wordpress.id

  posix_user {
    uid = 33 # www-data en Debian/Ubuntu (imagen oficial de WordPress)
    gid = 33
  }

  root_directory {
    path = "/wp-content"
    creation_info {
      owner_uid   = 33
      owner_gid   = 33
      permissions = "755"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-efs-ap-wp-content"
  })
}
