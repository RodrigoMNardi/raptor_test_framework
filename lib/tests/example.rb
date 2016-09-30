class Example < Raptor::TestSuite
  description do
    'Basic test'
  end

  configure do
    @count = 0
    @marble = 'Marble Variable'
  end

  verification '01' do
    @count += 40
    logger.info '*** Verification ***'
    assert_true(false, {issues: '6545, 54566', message: 'BUG example'})
  end

  verification '02' do
    @count += 40
    logger.info "==> #{@marble.inspect}"
    logger.info "==> #{@count}"

    assert_true true

    context 'Starting verification 2' do
      assert_true(false, {issues: '6545, 54566', message: 'BUG example'})
    end
  end

  verification '03 bomba' do
    raise 'BOOOOMMMMMMMMMMMMMM'
  end
end
