from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User
from .models import Profile,Company
from django.forms import ModelForm

class UserCreateForm(UserCreationForm):
    email = forms.EmailField(required=True)
    first_name = forms.CharField(required=True)
    last_name = forms.CharField(required=True)

    class Meta:
        model = User
        fields = ("username", "email", "password1", "password2","first_name",'last_name')

    def save(self, commit=True):
        user = super(UserCreateForm, self).save(commit=False)
        user.email = self.cleaned_data["email"]
        if commit:
            user.save()
        return user

class ProfileForm(ModelForm):

    class Meta:
        model = Profile
        exclude = ['created_at','updated_at','user','company']

    # def save(self,company,commit=True):
    #     profile = super(ProfileForm, self).save(commit=False)
    #     if commit:
    #         profile.save()
    #     return profile

class CompanyForm(ModelForm):

    class Meta:
        model = Company
        exclude = ['created_at','updated_at','slug']
