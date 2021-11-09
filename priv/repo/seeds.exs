# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Komplen.Repo.insert!(%Komplen.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# YOGHIRT Got the idea of seeding the database from here
# https://youtu.be/1YzAztAMgP4?t=2871
# https://elixirforum.com/t/seeding-database-with-relationships/13240/2
alias Komplen.Accounts.{User, Profile}
alias Komplen.Complaints.Complaint

user =
  Komplen.Repo.insert!(%User{
    username: "seed username",
    profile: %Profile{
      name: "seed name",
      phone: "seed phone",
      email: "seed email",
      ic_number: "seed ic_number"
    }
  })

Komplen.Repo.insert!(%Complaint{
  body: "seed body",
  title: "seed title",
  user_id: user.id
})
