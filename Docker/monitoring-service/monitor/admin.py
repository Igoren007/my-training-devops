from django.contrib import admin

# Register your models here.
from monitor.models import CustomUser

admin.site.register(CustomUser)