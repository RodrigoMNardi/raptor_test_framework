class Example_2 < Raptor::TestSuite
  description do
    'Basic test'
  end

  setup do
    @count = 0
    @marble = 'Marble Variable'
  end

  teardown do
    @count = 40
    @marble = 'PIPIPIPI'
  end

  verification '01' do
    @count += 40
    output '*** Verification ***'
    assert_true(false, {issues: '6545, 54566', message: 'BUG example'})
  end

  verification '02' do
    @count += 40
    output "==> #{@marble.inspect}"
    output "==> #{@count}"

    assert_true true

    context 'Starting verification 2' do
      output '==> BLOCK STARTED'
      assert_true(false, {issues: '6545, 54566', message: 'BUG example'})
    end
  end

  verification '03 bomba' do
    @count += 40
    output "==> #{@count}"
    @count += 40
    output "==> #{@count}"
    @count += 40
    output "==> #{@count}"
    @count += 40
    output "==> #{@count}"
    @count += 40

    raise 'BOOOOMMMMMMMMMMMMMM'
  end
end
