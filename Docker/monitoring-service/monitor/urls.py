from django.urls import path
from .views import *

urlpatterns = [
    path('home/', home, name='home'),
    path('create_host/', CreateHost.as_view(), name='create_host'),
    path('login/', LoginUser.as_view(), name='login'),
    path('register_user/', RegisterUser.as_view(), name='register_user'),
    path('logout/', logout_user, name='logout'),
    path('about/', about, name='about'),
    path('profile/', profile, name='profile'),
    path('settings/', settings, name='settings'),
    path('events/', events, name='events'),
    path('reports/', reports, name='reports'),
    path('edit_host/<int:pk>', HostEdit.as_view(), name='edit_host'),
    path('delete_host/<int:pk>', delete_host, name='delete_host'),
    path('host_list/', HostList.as_view(), name='host_list'),
]