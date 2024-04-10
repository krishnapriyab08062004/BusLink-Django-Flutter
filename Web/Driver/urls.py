from django.urls import path,include 
from Driver import views 

app_name = "webdriver"
urlpatterns = [
    path('driverhomepage/',views.driverhomepage, name="driverhomepage"),
    path('driverprofile/',views.driverprofile, name="driverprofile"),
    path('driverchangepassword/',views.driverchangepassword, name="driverchangepassword"),
    path('edit_driverprofile/',views.edit_driverprofile, name="edit_driverprofile"),
    path('drivercomplaints/',views.drivercomplaints, name="drivercomplaints"),
    path('driverfeedbacks/',views.driverfeedbacks, name="driverfeedbacks"),
    path('busdetails/',views.busdetails, name="busdetails"),
    path('delete_alert/<alid>',views.delete_alert, name="delete_alert"),
    path('alerts/',views.Alerts, name="alerts"),
    path('qrcode/',views.generate_qrcode,name='qrcode'),

   
]