class Record < ApplicationRecord
  enum ticker: [ :eth, :btc, :xrp ]
end
