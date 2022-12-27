# Execute this script with:
#   ruby -I lib examples/delegation_dci.rb

require "casting"
require "casting/context"

def log(message)
  puts("Transaction log: " + message.to_s)
end

# What it is
class Account
  include Casting::Client
  def initialize(name, balance)
    @name = name
    @balance = balance.to_i
  end
  attr_reader :name, :balance
  alias_method :to_s, :name
end

checking = Account.new(":checking:", 500)
savings = Account.new("~savings~", 2)

# What it does
class Transfer
  extend Casting::Context
  using Casting::Context

  initialize :amount, :source, :destination

  def execute
    log("#{source} has #{source.balance}")
    log("#{destination} has #{destination.balance}")
    result = catch(:result) do
      tell :destination, :increase_balance
    end
    log(result)
  end

  module Destination
    def increase_balance
      tell :source, :decrease_balance
      log("#{self} accepting #{role(:amount)} from #{role(:source)}")
      @balance = balance.to_i + role(:amount)
    end
  end

  module Source
    def decrease_balance
      log("#{self} releasing #{role(:amount)} to #{role(:destination)}")
      tell :source, :check_balance
      @balance = balance.to_i - role(:amount)
      log("#{self} released #{role(:amount)}. balance is now #{balance}")
    end

    def check_balance
      if balance < role(:amount)
        throw(:result, "#{self} has insufficient funds for withdrawal of #{role(:amount)}. Current balance is #{balance}")
      end
    end
  end
end

puts "Transferring..."
Transfer.new(amount: 30, source: checking, destination: savings).execute
Transfer.new(amount: 50, source: savings, destination: checking).execute
