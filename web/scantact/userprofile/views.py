from django.shortcuts import render,get_object_or_404
from django.http import HttpResponse,Http404
from django.template import RequestContext, loader
from .forms import UserCreateForm
from django.contrib.auth import authenticate, logout, login


def signup(request):
	if request.method == 'POST':
		form = UserCreateForm(request.POST)
		if form.is_valid():
			print("form is valid")
			form.save()
			username = request.POST['username']
			password = request.POST['password1']
			user = authenticate(username=username, password=password)
			user.backend = "django.contrib.auth.backends.ModelBackend"
			login(request, user)
			return HttpResponseRedirect('/')
		else:
			print("form is not valid")
	else:
		form = UserCreateForm()
	return render(request, 'registration/signup.html', { 'form': form })

def logout_view(request):
	context = {}
	return render(request,'userprofile/index.html',context)
