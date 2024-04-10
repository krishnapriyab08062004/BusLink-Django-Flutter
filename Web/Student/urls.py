from django.urls import path,include 
from Student import views 

app_name = "webstudent"

urlpatterns = [
    path('stuhomepage/',views.stuhomepage, name="stuhomepage"),
    path('studentprofile/',views.studentprofile, name="studentprofile"),
    path('changepassword/',views.changepassword, name="changepassword"),
     path('edit_studentprofile/',views.edit_studentprofile, name="edit_studentprofile"),
       path('choosestop/',views.choosestop, name="choosestop"),
     path('ajax_stop/',views.ajax_stop, name="ajax_stop"),
       path('editchoosestop/<str:csdid>',views.editchoosestop, name="editchoosestop"),
        path('stucomplaint/',views.stucomplaint, name="stucomplaint"),
          path('stufeedback/',views.stufeedback, name="stufeedback"),
           path('stupayment/',views.stupayment, name="stupayment"),
           
             path('payment_card/', views.payment_card, name='payment_card'),
             path('paymentinfo/', views.paymentinfo, name='paymentinfo'),
                 path('paymentloading/', views.paymentloading, name='paymentloading'),
                   path('success/', views.success, name='success'),
            
         
    # Add other URL patterns for the 'webstudent' app if needed
]
