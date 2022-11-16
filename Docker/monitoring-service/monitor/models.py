from django.contrib.auth.models import AbstractUser
from django.db import models

# Create your models here.

class CustomUser(AbstractUser):
    position = models.CharField(max_length=200)
    is_admin = models.BooleanField(default=False)


class Host(models.Model):
    title = models.CharField(max_length=500)
    ip_addr = models.GenericIPAddressField(protocol='IPv4')
    dns_name = models.CharField(max_length=200)
    created_at = models.DateTimeField(auto_now_add=True)
    time_interval = models.IntegerField()
    is_active = models.BooleanField(default=False)


class HostAvailability(models.Model):
    host = models.ForeignKey(Host, on_delete=models.CASCADE)
    time = models.DateTimeField(auto_now_add=True)
    status = models.BooleanField(default=False)