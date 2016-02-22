from django.shortcuts import render,get_object_or_404
from django.http import HttpResponse,Http404,HttpResponseRedirect
from django.template import RequestContext, loader
from .forms import UserCreateForm,ProfileForm,CompanyForm
from django.contrib.auth import authenticate, logout, login
from .models import Profile
from django.contrib.auth.decorators import login_required


def signup(request):
	if request.method == 'POST':
		form = UserCreateForm(request.POST)
		username = request.POST['username']
		password = request.POST['password1']
		first_name = request.POST["first_name"]
		last_name = request.POST['last_name']
		print(username,first_name,last_name)
		if form.is_valid():
			print("form is valid")
			form.save()
			user = authenticate(username=username, password=password)
			user.backend = "django.contrib.auth.backends.ModelBackend"
			login(request, user)
			return HttpResponseRedirect('/account/profile/eidt/')
		else:
			print("form is not valid")
	else:
		form = UserCreateForm()
	return render(request, 'registration/signup.html', { 'form': form })

def logout_view(request):
	context = {}
	logout(request)
	return HttpResponseRedirect('/')

@login_required
def profile(request):
	try:
		current_profile = Profile.objects.get(user=request.user)
		company = current_profile.company
		print(current_profile,"|",company)
	except:
		current_profile = None
		company = None

	return render(request,'userprofile/profile.html',{ 'user': request.user,'current_profile': current_profile,'company':company})


@login_required
def edit_profile(request):
	try:
		current_profile = Profile.objects.get(user=request.user)
		company = current_profile.company
		print(current_profile,"|",company)
	except:
		current_profile = None
		company = None

	if request.method == 'POST':
		form = ProfileForm(request.POST,request.FILES,instance=current_profile)
		companyform = CompanyForm(request.POST,request.FILES, instance=company)
		if form.is_valid() and companyform.is_valid():
			company = companyform.save()
			print("company saved : ",company)
			profile = form.save(commit=False)
			profile.company = company
			profile.user = request.user
			profile.save()
			form.save_m2m()
			print(profile)
			return HttpResponseRedirect('/account/profile/')
		else :
			print('form is not valid')
	else:
		if current_profile:
			print(current_profile.phone_number)
			form = ProfileForm(initial={'user': request.user,'phone_number':current_profile.phone_number,'profile_pic':
			current_profile.profile_pic,'position': current_profile.position,'work_number':current_profile.work_number,
			'work_fax':current_profile.work_fax,'work_email':current_profile.work_email,'work_address':current_profile.work_address
			},instance=current_profile)
		else :
			form = ProfileForm(initial={'user': request.user},instance=current_profile)
		if company:
			companyform = CompanyForm(initial={'company_name':company.company_name,'industry':company.industry,
			'company_number':company.company_number,'company_logo':company.company_logo},instance=company)
		else :
			companyform = CompanyForm(instance=company)

	return render(request,'userprofile/edit_profile.html',{ 'form': form,'companyform':companyform,'curr_profile_pic':current_profile.profile_pic })
