part of 'game_session_controller.dart';

extension GameSessionFeatureController on GameSessionController {
  Future<String?> acknowledgeCareerFinal() => _execute(
    action: _applicationService.acknowledgeCareerFinal,
    stateOf: (result) => result,
    message: (_) =>
        'Serbest oyun başladı. Holdingini büyütmeye devam edebilirsin.',
  );

  int get creditLimit => _applicationService.creditLimit(_state);

  Future<String?> borrow(int amount) => _execute(
    action: (state) => _applicationService.borrow(state, amount),
    stateOf: (result) => result,
    message: (_) => 'Kişisel cüzdana ₺$amount kredi aktarıldı.',
  );

  Future<String?> repayLoan(int amount) => _execute(
    action: (state) => _applicationService.repayLoan(state, amount),
    stateOf: (result) => result,
    message: (_) => 'Kredi borcuna ₺$amount ödeme yapıldı.',
  );

  Future<String?> invest(int amount, InvestmentPlan plan) => _execute(
    action: (state) => _applicationService.invest(state, amount, plan),
    stateOf: (result) => result,
    message: (_) => '${plan.label} yatırımına ₺$amount aktarıldı.',
  );

  PersonalEvent? get personalEvent => _applicationService.personalEvent(_state);

  Future<String?> resolvePersonalEvent(PersonalEventChoice choice) => _execute(
    action: (state) => _applicationService.resolvePersonalEvent(state, choice),
    stateOf: (result) => result,
    message: (_) => choice.outcome,
  );

  DailyGoalStatus get dailyGoalStatus =>
      _applicationService.dailyGoalStatus(_state);

  Future<String?> claimDailyGoal() => _execute(
    action: _applicationService.claimDailyGoal,
    stateOf: (result) => result,
    message: (_) => 'Günlük hedef ödülünü aldın: +₺${dailyGoalStatus.reward}.',
  );

  CompanyCheck checkCompanyEstablishment() =>
      _applicationService.checkCompanyEstablishment(_state);

  Future<String?> establishCompany() => _execute(
    action: _applicationService.establishCompany,
    stateOf: (result) => result,
    message: (_) => 'Şirketin kuruldu. Artık kendi işini büyütebilirsin.',
  );

  Future<String?> addCompanyCapital(int amount) => _execute(
    action: (state) => _applicationService.addCompanyCapital(state, amount),
    stateOf: (result) => result,
    message: (_) =>
        'Kişisel cüzdandan şirket kasasına ₺$amount sermaye aktarıldı.',
  );

  Future<String?> withdrawCompanyDividend(int grossAmount) => _execute(
    action: (state) =>
        _applicationService.withdrawCompanyDividend(state, grossAmount),
    stateOf: (result) => result,
    message: (_) {
      final tax = CompanyTreasuryService.dividendTax(grossAmount);
      final net = CompanyTreasuryService.dividendNet(grossAmount);
      return 'Şirket kasasından ₺$grossAmount çekildi; ₺$tax vergi sonrası '
          'kişisel cüzdana ₺$net aktarıldı.';
    },
  );

  Future<String?> setCompanyBudgetLevel(
    CompanyBudgetCategory category,
    CompanyBudgetLevel level,
  ) => _execute(
    action: (state) =>
        _applicationService.setCompanyBudgetLevel(state, category, level),
    stateOf: (result) => result,
    message: (_) =>
        '${category.label} bütçesi ${level.label.toLowerCase()} oldu.',
  );

  Future<String?> resolveCompanyDecision(CompanyDecisionChoice choice) =>
      _execute(
        action: (state) =>
            _applicationService.resolveCompanyDecision(state, choice),
        stateOf: (result) => result,
        message: (_) => '${choice.title} kararı uygulandı.',
      );

  Future<String?> applyCompanyAutomation(
    CompanyAutomationPreset preset,
  ) => _execute(
    action: (state) =>
        _applicationService.applyCompanyAutomation(state, preset),
    stateOf: (result) => result.state,
    message: (result) =>
        '${preset.label} planı uygulandı: ${result.managerCount} bayi yöneticisi ve ${result.raiseCount} zam talebi düzenlendi. Aktif proje aynı ekiple otomatik yenilenir.',
  );

  Future<String?> tickToNextDay() {
    final hours = 24 - _state.hour;
    return tick(hours: hours <= 0 ? 24 : hours);
  }

  Future<String?> recruitEmployee(CompanyEmployee employee) => _execute(
    action: (state) =>
        _applicationService.recruitEmployee(state, employee: employee),
    stateOf: (result) => result,
    message: (_) =>
        'Çalışan ekibe katıldı. İşe alım ücretsiz; günlük maaş gideri artık uygulanacak.',
  );

  Future<String?> dismissEmployee(int employeeId) => _execute(
    action: (state) =>
        _applicationService.dismissEmployee(state, employeeId: employeeId),
    stateOf: (result) => result,
    message: (_) =>
        'Çalışanın işten çıkarıldı. Maaş gideri ve proje katkısı güncellendi.',
  );

  EmployeeDevelopmentCheck checkEmployeeDevelopment(int employeeId) =>
      _applicationService.checkEmployeeDevelopment(_state, employeeId);

  Future<String?> developEmployee(int employeeId) => _execute(
    action: (state) => _applicationService.developEmployee(state, employeeId),
    stateOf: (result) => result,
    message: (result) {
      final employee = result.employees.firstWhere(
        (current) => current.id == employeeId,
      );
      return '${employee.name} performansını %${employee.performance} seviyesine çıkardı.';
    },
  );

  EmployeePromotionCheck checkEmployeePromotion(int employeeId) =>
      _applicationService.checkEmployeePromotion(_state, employeeId);

  Future<String?> promoteEmployee(int employeeId) => _execute(
    action: (state) => _applicationService.promoteEmployee(state, employeeId),
    stateOf: (result) => result,
    message: (result) {
      final employee = result.employees.firstWhere(
        (current) => current.id == employeeId,
      );
      return '${employee.name}, ${employee.seniority.label} kıdemine terfi etti.';
    },
  );

  Future<String?> respondToEmployeeRaise(
    int employeeId, {
    required bool accept,
  }) => _execute(
    action: (state) => _applicationService.respondToEmployeeRaise(
      state,
      employeeId,
      accept: accept,
    ),
    stateOf: (result) => result,
    message: (_) =>
        accept ? 'Zam talebi kabul edildi.' : 'Zam talebi reddedildi.',
  );

  CompanyCheckResult checkBranchOpen(City city) =>
      _applicationService.checkBranchOpen(_state, city);

  List<CompanyEmployee> branchCandidates(CompanyBranch branch) =>
      _applicationService.branchCandidates(_state, branch);

  Future<String?> openBranch(City city) => _execute(
    action: (state) => _applicationService.openBranch(state, city),
    stateOf: (result) => result,
    message: (_) => '${city.name} şehrinde bayin açıldı.',
  );

  Future<String?> recruitBranchEmployee(int cityId, CompanyEmployee employee) =>
      _execute(
        action: (state) => _applicationService.recruitBranchEmployee(
          state,
          cityId: cityId,
          employee: employee,
        ),
        stateOf: (result) => result,
        message: (_) => 'Çalışan bayine katıldı.',
      );

  Future<String?> dismissBranchEmployee(int cityId, int employeeId) => _execute(
    action: (state) => _applicationService.dismissBranchEmployee(
      state,
      cityId: cityId,
      employeeId: employeeId,
    ),
    stateOf: (result) => result,
    message: (_) => 'Bayi çalışanı işten çıkarıldı.',
  );

  Future<String?> setBranchManager(int cityId, CompanyEmployee? employee) =>
      _execute(
        action: (state) => _applicationService.setBranchManager(
          state,
          cityId: cityId,
          employeeId: employee?.id,
        ),
        stateOf: (result) => result,
        message: (_) => employee == null
            ? 'Bayi yöneticisi kaldırıldı.'
            : '${employee.name} bayi yöneticisi oldu.',
      );

  Future<String?> setBranchLocalGoal(int cityId, CompanyBranchLocalGoal goal) =>
      _execute(
        action: (state) => _applicationService.setBranchLocalGoal(
          state,
          cityId: cityId,
          goal: goal,
        ),
        stateOf: (result) => result,
        message: (_) => 'Yerel hedef “${goal.label}” olarak güncellendi.',
      );

  Future<String?> setBranchSpecialty(int cityId, CompanySpecialty specialty) =>
      _execute(
        action: (state) => _applicationService.setBranchSpecialty(
          state,
          cityId: cityId,
          specialty: specialty,
        ),
        stateOf: (result) => result,
        message: (_) =>
            'Bayi uzmanlığı “${specialty.label}” olarak güncellendi.',
      );

  EmployeeDevelopmentCheck checkBranchEmployeeDevelopment(
    int cityId,
    int employeeId,
  ) => _applicationService.checkBranchEmployeeDevelopment(
    _state,
    cityId,
    employeeId,
  );

  Future<String?> developBranchEmployee(int cityId, int employeeId) => _execute(
    action: (state) =>
        _applicationService.developBranchEmployee(state, cityId, employeeId),
    stateOf: (result) => result,
    message: (result) {
      final branch = result.branches.firstWhere(
        (current) => current.cityId == cityId,
      );
      final employee = branch.employees.firstWhere(
        (current) => current.id == employeeId,
      );
      return '${employee.name} performansını %${employee.performance} seviyesine çıkardı.';
    },
  );

  EmployeePromotionCheck checkBranchEmployeePromotion(
    int cityId,
    int employeeId,
  ) => _applicationService.checkBranchEmployeePromotion(
    _state,
    cityId,
    employeeId,
  );

  Future<String?> promoteBranchEmployee(int cityId, int employeeId) => _execute(
    action: (state) =>
        _applicationService.promoteBranchEmployee(state, cityId, employeeId),
    stateOf: (result) => result,
    message: (_) => 'Bayi çalışanı terfi etti.',
  );

  Future<String?> respondToBranchEmployeeRaise(
    int cityId,
    int employeeId, {
    required bool accept,
  }) => _execute(
    action: (state) => _applicationService.respondToBranchEmployeeRaise(
      state,
      cityId,
      employeeId,
      accept: accept,
    ),
    stateOf: (result) => result,
    message: (_) => accept
        ? 'Bayi çalışanının zam talebi kabul edildi.'
        : 'Bayi çalışanının zam talebi reddedildi.',
  );

  CompanyCheckResult checkBranchUpgrade(int cityId) =>
      _applicationService.checkBranchUpgrade(_state, cityId);

  Future<String?> upgradeBranch(int cityId) => _execute(
    action: (state) => _applicationService.upgradeBranch(state, cityId),
    stateOf: (result) => result,
    message: (result) {
      final branch = result.branches.firstWhere(
        (current) => current.cityId == cityId,
      );
      return 'Bayi seviye ${branch.level} oldu; kapasite ve gelir arttı.';
    },
  );

  AssetCheck checkHome(HomeAsset home, City city) =>
      _applicationService.checkHome(_state, home, city);

  Future<String?> buyHome(HomeAsset home, City city) => _execute(
    action: (state) => _applicationService.buyHome(state, home, city),
    stateOf: (result) => result,
    message: (_) =>
        '${home.name} satın alındı. Bu şehirde konut kirası ödemezsin.',
  );

  Future<String?> sellHome(HomeAsset home) => _execute(
    action: (state) => _applicationService.sellHome(state, home),
    stateOf: (result) => result,
    message: (_) =>
        '${home.name} ₺${AssetService().homeSaleValue(home)} karşılığında satıldı.',
  );

  Future<String?> rentOutHome(HomeAsset home) => _execute(
    action: (state) => _applicationService.rentOutHome(state, home),
    stateOf: (result) => result,
    message: (_) =>
        '${home.name} aylık ₺${AssetService().monthlyRent(home)} karşılığında kiraya verildi.',
  );

  Future<String?> stopRentingHome(HomeAsset home) => _execute(
    action: (state) => _applicationService.stopRentingHome(state, home),
    stateOf: (result) => result,
    message: (_) => '${home.name} kiradan çıkarıldı.',
  );

  AssetCheck checkCar(CarAsset car) =>
      _applicationService.checkCar(_state, car);

  Future<String?> buyCar(CarAsset car) => _execute(
    action: (state) => _applicationService.buyCar(state, car),
    stateOf: (result) => result,
    message: (_) =>
        '${car.name} satın alındı. Şehir değiştirirken avantaj kazanırsın.',
  );

  Future<String?> sellCar(CarAsset car) => _execute(
    action: (state) => _applicationService.sellCar(state, car),
    stateOf: (result) => result,
    message: (_) =>
        '${car.name} ₺${AssetService().carSaleValue(car)} karşılığında satıldı.',
  );

  CompanyCheck checkCompanyUpgrade() =>
      _applicationService.checkCompanyUpgrade(_state);

  Future<String?> upgradeCompany() => _execute(
    action: _applicationService.upgradeCompany,
    stateOf: (result) => result,
    message: (result) => 'Şirketin seviye ${result.companyLevel} oldu.',
  );

  Future<String?> selectCompanyProject(CompanyProject project) => _execute(
    action: (state) => _applicationService.selectCompanyProject(state, project),
    stateOf: (result) => result,
    message: (_) => '${project.name} projesi seçildi.',
  );

  Future<String?> setCompanyProjectEmployeeAssignment(
    CompanyProject project,
    CompanyEmployee employee, {
    required bool assigned,
  }) => _execute(
    action: (state) => _applicationService.setCompanyProjectEmployeeAssignment(
      state,
      project: project,
      employeeId: employee.id,
      assigned: assigned,
    ),
    stateOf: (result) => result,
    message: (_) => assigned
        ? '${employee.name} proje ekibine atandı.'
        : '${employee.name} proje ekibinden çıkarıldı.',
  );

  Future<String?> selectCompanyCompetitionStrategy(
    CompanyCompetitionStrategy strategy,
  ) => _execute(
    action: (state) =>
        _applicationService.selectCompanyCompetitionStrategy(state, strategy),
    stateOf: (result) => result,
    message: (_) =>
        '${strategy.title} bu sezonun rekabet stratejisi olarak seçildi.',
  );

  Future<String?> advanceCompanyProject() => _execute(
    action: _applicationService.advanceCompanyProject,
    stateOf: (result) => result.state,
    message: (result) => result.message,
  );

  CompanyDealCheck checkCompanyDeal(CompanyDeal deal) =>
      _applicationService.checkCompanyDeal(_state, deal);

  Future<String?> completeCompanyDeal(CompanyDeal deal) => _execute(
    action: (state) => _applicationService.completeCompanyDeal(state, deal),
    stateOf: (result) => result,
    message: (_) =>
        '${deal.title}: ${deal.type.label} tamamlandı. '
        'Şirket kasasından ₺${deal.cost} ödendi; değer +₺${deal.valuationGain}, '
        'itibar +${deal.reputationGain}, pazar payı +%${deal.marketShareGain}.',
  );
}
