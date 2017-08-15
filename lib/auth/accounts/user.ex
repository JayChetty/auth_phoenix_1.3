defmodule Auth.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Auth.Accounts.User


  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password_hash])
    |> validate_required([:email])
  end

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
end
