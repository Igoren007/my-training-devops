from django.contrib.auth.forms import UserCreationForm, AuthenticationForm
from django import forms
from django.forms import models

from monitor.models import CustomUser, Host


class CreateCustomUserForm(UserCreationForm):
    """
        Форма для создания аккаунта нового пользователя
    """
    username = forms.CharField(label='Имя пользователя', widget=forms.TextInput(attrs={'placeholder':'Имя пользователя'}))
    position = forms.CharField(label='Должность', widget=forms.TextInput(attrs={'placeholder': 'Должность'}))
    first_name = forms.CharField(label='Имя', widget=forms.TextInput(attrs={'placeholder': 'Имя'}))
    last_name = forms.CharField(label='Фамилия', widget=forms.TextInput(attrs={'placeholder': 'Фамилия'}))
    is_admin = forms.BooleanField(required=False, label='Права администратора')
    password1 = forms.CharField(label='Пароль', widget=forms.PasswordInput(attrs={'placeholder': 'Пароль'}))
    password2 = forms.CharField(label='Повтор пароля', widget=forms.PasswordInput(attrs={'placeholder': 'Повтор пароля'}))

    class Meta:
        model = CustomUser
        fields = ('username', 'position', 'first_name', 'last_name', 'is_admin', 'password1', 'password2')


class LoginCustomUserForm(AuthenticationForm):
    username = forms.CharField(widget=forms.TextInput(attrs={'placeholder': 'Имя пользователя'}))
    password = forms.CharField(widget=forms.PasswordInput(attrs={'placeholder': 'Пароль'}))


class CreateHostForm(forms.ModelForm):
    title = forms.CharField(label='Заголовок', widget=forms.TextInput(attrs={'placeholder': 'Заголовок'}))
    ip_addr = forms.CharField(label='IP адрес', widget=forms.TextInput(attrs={'placeholder': 'IP'}))
    dns_name = forms.CharField(label='DNS имя', widget=forms.TextInput(attrs={'placeholder': 'DNS имя'}))
    time_interval = forms.IntegerField(label='Интервал мониторинга, мин', widget=forms.NumberInput(attrs={'placeholder': 'Интервал'}))
    is_active = forms.BooleanField(required=False, label='Необходимость мониторинга')

    class Meta:
        model = Host
        fields = ('title', 'ip_addr', 'dns_name', 'time_interval', 'is_active')


class HostEditForm(forms.ModelForm):
    class Meta:
        model = Host
        fields = ('title', 'ip_addr', 'dns_name', 'time_interval', 'is_active')
        widgets = {
            'title': forms.TextInput(attrs={'placeholder': 'Заголовок'}),
            'ip_addr': forms.TextInput(attrs={'placeholder': 'IP'}),
            'dns_name': forms.TextInput(attrs={'placeholder': 'DNS имя'}),
            'time_interval': forms.NumberInput(attrs={'placeholder': 'Интервал'})
            }
        labels = {
            'title': 'Заголовок',
            'ip_addr': 'IP адрес',
            'dns_name': 'DNS имя',
            'time_interval': 'Интервал мониторинга, мин',
            'is_active': 'Необходимость мониторинга'
        }