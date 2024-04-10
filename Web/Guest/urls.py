from django.urls import path
from Guest import views

app_name="webguest"

urlpatterns = [
       path('userreg/',views.userreg,name="userreg"), 
       path('ajax_place',views.ajax_place,name="ajaxplace"),
       path('driverreg/',views.driverreg,name="driverreg"),
       path('login/',views.login,name="login"),
        path('ajax_course',views.ajax_course,name="ajaxcourse"),
   
       
    
    
]
