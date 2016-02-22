from django.db import models
from django.contrib.auth.models import User
import datetime
from django.utils import timezone
from django.template.defaultfilters import slugify
from phonenumber_field.modelfields import PhoneNumberField


class Company(models.Model):
    company_name = models.CharField(max_length=500,blank=True)
    industry = models.CharField(max_length=500,blank=True)
    company_number = PhoneNumberField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    slug = models.SlugField(max_length=200, unique=True)
    company_logo = models.ImageField(upload_to="uploads/company/logo/",null=True,blank=True)

    class Meta:
        verbose_name_plural = "Companies"

    def __str__(self):
        return self.company_name

    def save(self, *args, **kwargs):
        if not self.id:
            self.slug = slugify(self.company_name)
        return super(Company,self).save(*args, **kwargs)


class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    phone_number = PhoneNumberField()
    profile_pic = models.ImageField(upload_to="uploads/users/",null=True,blank=True)
    company = models.ForeignKey(Company,on_delete=models.CASCADE)
    # work
    position = models.CharField(max_length=400,blank=True)
    work_number = PhoneNumberField(blank=True)
    work_fax = PhoneNumberField(blank=True)
    work_email = models.EmailField(blank=True)
    work_address = models.TextField(blank=True)
    updated_at = models.DateTimeField(auto_now=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.user.username
