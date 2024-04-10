from django.urls import path
from Admin import views

app_name="webadmin"

urlpatterns = [
    path('admin/',views.adminreg,name="admin"),
    path('homepage/',views.homepage,name="homepage"),
    path('adminprofile/',views.adminprofile,name="adminprofile"),
    path('edit_adminprofile/',views.edit_adminprofile,name="edit_adminprofile"),

    path('dist/',views.district,name="district"), 
    path('delete_dis/<str:delid>',views.delete_dis,name="delete_dis"),
    path('edit_dis/<str:editid>',views.edit_dis,name="edit_dis"),

    path('place/',views.place,name="place"),
    path('delete_place/<str:plid>',views.delete_place,name="delete_place"),
    path('edit_place/<str:id>',views.edit_place,name="edit_place"),

    path('route/',views.route,name="route"),
    path('delete_route/<str:rid>',views.delete_route,name="delete_route"),
    path('edit_route/<str:eid>',views.edit_route,name="edit_route"),
    
    path('stop/',views.stop,name="stop"),
    path('delete_stop/<str:sdid>',views.delete_stop,name="delete_stop"),
    
    path('dep/',views.dep,name="dep"),
    path('delete_dep/<str:depid>',views.delete_dep,name="delete_dep"),
   
    path('course/',views.course,name="course"),
    path('delete_course/<str:cid>',views.delete_course,name="delete_course"),

    path('bus/',views.bus,name="bus"),
    path('delete_bus/<str:bid>',views.delete_bus,name="delete_bus"),
    path('edit_bus/<str:busid>',views.edit_bus,name="edit_bus"),


    path('verifystudent/',views.verifystudent,name="verifystudent"),
    path('accept_student/<str:accid>',views.accept_student,name="accept_student"),
    path('reject_student/<str:rejid>',views.reject_student,name="reject_student"),

    path('verifydriver/',views.verifydriver,name="verifydriver"),
    path('reject_driver/<str:rejdid>',views.reject_driver,name="reject_driver"),
    path('accept_driver/<str:accdid>',views.accept_driver,name="accept_driver"),

    path('assigndriver/',views.assigndriver,name="assigndriver"),
     path('changerequest/',views.changerequest,name="changerequest"),
      path('request_accept/<changeid>',views.request_accept,name="request_accept"),
       path('request_reject/<rejectid>',views.request_reject,name="request_reject"),
       path('viewcomplaints/',views.viewcomplaints,name="viewcomplaints"),

       path('replycomplaints/<id>',views.replycomplaints,name="replycomplaints"),
        path('viewfeedbacks/',views.viewfeedbacks,name="viewfeedbacks"),
     
   
    
   
]
