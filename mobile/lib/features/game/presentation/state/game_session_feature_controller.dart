part of 'game_session_controller.dart';

extension GameSessionFeatureController on GameSessionController {
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

  Future<String?> advanceCompanyProject() => _execute(
    action: _applicationService.advanceCompanyProject,
    stateOf: (result) => result.state,
    message: (result) => result.message,
  );
}
