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
alias Komplen.Accounts.{User, Profile, Admin}
alias Komplen.Complaints.{Complaint, Vouch}

user1 =
  Komplen.Repo.insert!(%User{
    username: "kamal",
    profile: %Profile{
      name: "kamal",
      phone: "0123456789",
      email: "abc@gmail.com",
      ic_number: "000000000000"
    }
  })

user2 =
  Komplen.Repo.insert!(%User{
    username: "arieff",
    profile: %Profile{
      name: "arieff",
      phone: "9876543210",
      email: "zyx@gmail.com",
      ic_number: "111111111111"
    }
  })

Komplen.Repo.insert!(%Admin{
  user: user1
})

complaint =
  Komplen.Repo.insert!(%Complaint{
    body: "seed body",
    title: "seed title",
    user_id: user1.id
  })

Komplen.Repo.insert!(%Vouch{
  user_id: user1.id,
  complaint_id: complaint.id
})

Komplen.Repo.insert!(%Vouch{
  user_id: user2.id,
  complaint_id: complaint.id
})

room = Komplen.Repo.insert!(%Komplen.Chat.Room{
  complaint_id: complaint.id
})

Komplen.Repo.insert!(%Komplen.Chat.Message{
  message: "first message",
  user_id: user1.id,
  room_id: room.id
})
