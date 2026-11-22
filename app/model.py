TABLES = {
 'branch':['branch_id','branch_name','city','address','phone'],
 'employee':['employee_id','branch_id','first_name','last_name','position','salary','hire_date'],
 'customer':['customer_id','first_name','last_name','phone','email','birth_date','licence_number'],
 'vehicle_category':['category_id','category_name','description'],
 'vehicle':['vehicle_id','category_id','branch_id','plate','brand','model','model_year','mileage_km','daily_rate','operational_status'],
 'reservation':['reservation_id','customer_id','vehicle_id','start_at','end_at','agreed_daily_rate','status'],
 'rental':['rental_id','reservation_id','employee_id','pickup_at','return_at','pickup_km','return_km'],
 'payment':['payment_id','rental_id','amount','payment_method','paid_at'],
}
NULLABLE={'email','description','return_at','return_km'}
