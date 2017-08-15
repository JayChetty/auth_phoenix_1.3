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
  mix phx.gen.html Accounts User users email:unique password_hash:string
```
```elixir
defmodule Play.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :password_hash, :string

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
```
This will create the start point for our accounts system, lib/auth/accounts and the web interface lib/auth_web/
Follow the instructions to add the resource to our router and migrate to create the database table.

##Accounts System
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

###Setting up Password Hashing
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

###Hashing passwords
Great  now our system will take in passwords, and store a hash. Let's actually hash them using the comeonin library.

As our passwords will be hashed we cannot determine what to expect.  We will get by this by loosening the restriction test to just check a password hash exists and it is over length 16.  (We could make the system more flexible here allowing it to receive in a hashing algorithm - allowing us to by-pass the password hashing,  however as I don't see the algorithm needing to change in the future so I feel it is not worth the additional complexity- this is highly debatable.  I also like giving at least giving the hashing algorithm a spin in the test)

<!-- We'll make our system be able to take in a hashing algorithm so we can test it with a simple one,  by default it will use come one in. -->

accounts.test.exs
``` elixir


def user_fixture(attrs \\ %{}) do
  {:ok, user} =
    attrs
    |> Enum.into(@valid_attrs)
    |> Accounts.create_user()
  user
end
...
test "create_user/1 with valid data creates a user" do
  assert {:ok, %User{} = user} = Accounts.create_user()
  assert user.email == "some email"
  assert user.password_hash
  assert String.length(user.password_hash) > 16
end

```

mix.exs
``` elixir
defp deps do
  [...{:comeonin, "~> 4.0"},
  {:bcrypt_elixir, "~> 0.12.0"}
end
```

```elixir
  def put_pass_hash(changeset, ) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        changeset
          |> put_change(:password_hash, Comeonin.Bcrypt.hashpwsalt(password))
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

Algorithm intentionally slow.  Let's speed it up for tests.

config/test.exs
```elixir
  config :bcrypt_elixir, :log_rounds, 4
```


###Validations
Let's make sure our data meets valid.

Email over 8 characters.  Add a test
```elixir
test "create_user/1 with short password data returns error changeset" do
  short_password_attrs = %{ @valid_attrs | password: "pass" }
  assert {:error, %Ecto.Changeset{}} = Accounts.create_user(short_password_attrs)
end
```
mix test

user.ex
```elixir
def registration_changeset(%User{} = user, attrs) do
  user
  |> changeset(attrs)
  |> cast(attrs, [:password])
  |> validate_length(:password, min: 8)
  |> put_pass_hash()
end
```

We setup our database to have a to create unique index for users,  let's test this.
accounts_test.exs
```elixir
test "create_user/1 with taken email returns error changeset" do
  {:ok, %User{} = _} = Accounts.create_user(@valid_attrs)
  assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@valid_attrs)
end
```

Great our system is working nicely.  Feel free to add more validations for our user. Let's now update our web interface to use our new system.

##Web interface for accounts system
mix phx.server
Update the user form to expect passwords rather than hashes
```elixir
  <div class="form-group">
    <%= label f, :email, class: "control-label" %>
    <%= email_input f, :email, class: "form-control" %>
    <%= error_tag f, :email %>
  </div>

  <div class="form-group">
    <%= label f, :password, class: "control-label" %>
    <%= password_input f, :password, class: "form-control" %>
    <%= error_tag f, :password %>
  </div>
```

Sugar sweet.  users/new gives us a decent sign up page.
Show gives us a details page. And on edit they can update their details.
List is somethign that only
