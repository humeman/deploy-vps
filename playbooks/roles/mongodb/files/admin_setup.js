db = connect( 'mongodb://localhost/admin' );

db.createUser(
    {
        user: "admin",
        pwd: "{{ mongodb['admin_password'] }}",
        roles: [ { role: "userAdminAnyDatabase", db: "admin" }]
    }
)