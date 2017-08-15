# Auth
Example application for setting up user registration and token distribution in phoenix. 1.3

Setup application
```
  mix phx.new auth
  mix ecto.create
  mix phx.server
```

##Registration
We would like a user to be able to register accounts(signup) for our application.
Let's build an accounts system to allow for this.

We will use the phoenix command line generators to create a start point for our user accounts system.  

```
  mix phx.gen.html Accounts User users email:string password_hash:string
```
This will create the start point for our accounts system, lib/auth/accounts and the web interface lib/auth_web/
Follow the instructions to add the resource to our router and migrate to create the database table.

###Accounts System
Let's run our tests
```
 mix test
```
All good. Let's look at the test for our accounts system.
```
test/auth/accounts/accounts_test.exs
```

Give us a good idea on what this system is set up todo.  Our accounts system encapsulates all the CRUDDYness for our Users.  This is a great start point.  


Not only has phx.gen created this.  It has created an web interface for our user accounts via HTML.

Spin up the server
```
  mix.phx.server
```
go to localhost:4000/users/new

This is almost what we wanted right.  Cool, thanks phoenix.  But we shouldn't expect our users to hash their own password.  We'll do that for them (aren't we kind).  Let's alter our system to do this.

####Setting up Password Hashing
Our interface for our accounts system shouldn't deal with hashed passwords. It will do that for us.  Let's alter our tests so that the we use passwords.

``` elixir
@valid_attrs %{email: "some email", password: "some password_hash"}
@update_attrs %{email: "some updated email"}
@invalid_attrs %{email: nil, password_hash: nil}

#Update functions to have the password hash we are going to hard code
assert user.password_hash == "password_hash"
```
All our tests fail.  Our accounts system expects there to be a password hash. Let's change this.

``` elixir
|> validate_required([:email])
```

Now only two tests fail.  They expect a password hash,  but now that we haven't passed it in, it hasn't been set. Let's fix this.

``` elixir
def registration_changeset(%User{} = user, attrs) do
  user
  |> changeset(attrs)
  |> cast(attrs, [:password])
  |> put_pass_hash()
end
```
```elixir
  def put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: _}} ->
        changeset
          |> put_change(:password_hash, "password_hash")
          |> put_change(:password, nil)
      _ ->
        changeset
    end
  end
```

####Hashing passwords
Great  now our system will take in passwords, and store a hash. Let's actually hash them using the comeonin library.

Testing randomness? Hard, and we'll trust comonin to be doing it's job.  We'll make our system be able to take in a hashing algorithm so we can test it with a simple one,  by default it will use come one in.

accounts.test.exs
``` elixir
def dummy_hashing_algorithm(_) do
  "password_hash"
end

def user_fixture(attrs \\ %{}) do
  {:ok, user} =
    attrs
    |> Enum.into(@valid_attrs)
    |> Accounts.create_user(&dummy_hashing_algorithm/1)
  user
end
...
test "create_user/1 with valid data creates a user" do
  hashing_algorithm = fn(_) -> "password_hash" end
  assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs, &dummy_hashing_algorithm/1)
  assert user.email == "some email"
  assert user.password_hash == "password_hash"
end

test "create_user/1 with invalid data returns error changeset" do
  hashing_algorithm = fn(_) -> "password_hash" end
  assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs, &dummy_hashing_algorithm/1)
end
```

accounts.ex
```elixir
  def create_user(attrs \\ %{}, hashing_algorithm) do
    %User{}
    |> User.registration_changeset(attrs, hashing_algorithm)
    |> Repo.insert()
  end
```

user.ex
```elixir
  def registration_changeset(%User{} = user, attrs, hashing_algorithm) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> put_pass_hash(hashing_algorithm)
  end

  def put_pass_hash(changeset, hashing_algorithm) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        changeset
          |> put_change(:password_hash, hashing_algorithm.(password))
          |> put_change(:password, nil)
      _ ->
        changeset
    end
  end
```

Out system is ready to take an algorithm to hash passwords.  We'll do this using the comeonin library. Let's set it up to use this by default
``` elixir
test "create_user/1 with no algorithm uses default hashing algorithm" do
  assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
  assert user.email == "some email"
  assert user.password_hash
end
```
mix.exs
``` elixir
defp deps do
  [...{:comeonin, "~> 4.0"},
  {:bcrypt_elixir, "~> 0.12.0"}
end
```
mix deps.get
accounts.ex
```elixir
  def create_user(attrs \\ %{}, hashing_algorithm \\ &default_hashing_algorithm/1) do
    %User{}
    |> User.registration_changeset(attrs, hashing_algorithm)
    |> Repo.insert()
  end

  def default_hashing_algorithm(password) do
    Comeonin.Bcrypt.hashpwsalt(password)
  end
```
<!-- Let's set up our test to expect a password -->
<!-- We would like to be able to create users and store them in the database.  

Phoenix uses the Ecto library to handle data persitance.  We can use the command line tools to help us generate a schema for the User table. -->





###Web interface for accounts system
<!-- We will do this by allowing them to get a form.
http://localhost:4000/registrations/new -->
resources "/users", UserController
