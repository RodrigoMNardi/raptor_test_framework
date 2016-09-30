class Example < Raptor::TestSuite
  configure do
    @count = 0
    @marble = 'Marble Variable'
  end

  verification '01' do
    @count += 40
    logger.info '*** Verification ***'
  end

  verification '02' do
    @count += 40
    logger.info "==> #{@marble.inspect}"
    logger.info "==> #{@count}"

    context 'Starting verification 2' do
      assert_true(false, {issues: '6545, 54566', message: 'BUG example'})
    end
  end
end
