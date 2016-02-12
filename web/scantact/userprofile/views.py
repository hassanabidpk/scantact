from django.shortcuts import render,get_object_or_404
from django.http import HttpResponse,Http404
from django.template import RequestContext, loader



def index(request):
	context = {}
	return render(request,'userprofile/index.html',context)


	


