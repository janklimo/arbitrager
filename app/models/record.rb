class Record < ApplicationRecord
  enum ticker: [ :eth, :btc ]
end
