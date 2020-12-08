	<section class="full-box cover dashboard-sideBar">
		<div class="full-box dashboard-sideBar-bg btn-menu-dashboard"></div>
		<div class="full-box dashboard-sideBar-ct">
			<!--SideBar Title -->
			<div class="full-box text-uppercase text-center text-titles dashboard-sideBar-title">
				<?php echo COMPANY; ?> <i class="zmdi zmdi-close btn-menu-dashboard visible-xs"></i>
			</div>
			<!-- SideBar User info -->
			<div class="full-box dashboard-sideBar-UserInfo">
				<figure class="full-box">
					<img src="<?php echo SERVERURL; ?>vistas/assets/avatars/Male3Avatar.png" alt="UserIcon">
					<figcaption class="text-center text-titles text-uppercase"><?php echo $_SESSION['nombre']; ?></figcaption>
				</figure>
				<ul class="full-box list-unstyled text-center">
					<?php if ($_SESSION['tipo']!=2){ ?>
						<li>
							<a href="<?php echo SERVERURL; ?>admin/" title="Usuarios">
								<i class="zmdi zmdi-account-circle"></i>
							</a>
						</li>
					<?php }else{ ?>
						<li>
							<a href="<?php echo SERVERURL;?>admin/<?php echo $lc->encryptar($_SESSION['id_user']); ?>" title="Usuarios">
								<i class="zmdi zmdi-account-circle"></i>
							</a>
						</li>
					<?php } ?>
					<li>
						<a href="<?php echo $lc->encryptar($_SESSION['token']); ?>" title="Salir del sistema" class="btn-exit-system">
							<i class="zmdi zmdi-power"></i>
						</a>
					</li>
				</ul>
			</div>
			<!-- SideBar Menu -->
			<ul class="list-unstyled full-box dashboard-sideBar-Menu">
				<li>
					<a href="<?php echo SERVERURL; ?>embarque/">
						<i class="zmdi zmdi-truck zmdi-hc-fw"></i> EMBARQUE
					</a>
				</li>
				<?php if ($_SESSION['tipo']!=2): ?>
					<li>
						<a href="<?php echo SERVERURL; ?>gastos">
							<i class="zmdi zmdi-money zmdi-hc-fw"></i>
							GASTOS DE EMBARQUES
						</a>
					</li>
					<li>
						<a href="<?php echo SERVERURL; ?>banco">
							<i class="zmdi zmdi-chart zmdi-hc-fw"></i>
							CUENTA BANCO
						</a>
					</li>
					<?php endif ?>
					<li>
						<a href="<?php echo SERVERURL; ?>consultas">
							<i class="zmdi zmdi-search-replace zmdi-hc-fw"></i>
							CONSULTAR
						</a>
					</li>
				<li>
					<a href="<?php echo SERVERURL; ?>productores">
						<i class="zmdi zmdi-balance zmdi-hc-fw"></i> PRODUCTORES
					</a>
				</li>
				<li>
					<a href="<?php echo SERVERURL; ?>trabajador/">
						<i class="zmdi zmdi-card zmdi-hc-fw"></i> TRABAJADORES
					</a>
				</li>
				<?php if ($_SESSION['tipo']!=2): ?>
				<li>
					<a href="<?php echo SERVERURL; ?>update/">
						<i class="zmdi zmdi-refresh-sync-problem zmdi-hc-fw"></i> ACT. EMB. ANTERIOR
					</a>
				</li>
				<li>
					<a href="#!" class="btn-sideBar-SubMenu">
						<i class="zmdi zmdi-case zmdi-hc-fw"></i> ADMINISTRAR <i class="zmdi zmdi-caret-down pull-right"></i>
					</a>
					<ul class="list-unstyled full-box">
						<li>
							<a href="<?php echo SERVERURL; ?>company/"><i class="zmdi zmdi-city-alt zmdi-hc-fw"></i> EMPRESA</a>
						</li>
						<li>
							<a href="<?php echo SERVERURL; ?>admin/"><i class="zmdi zmdi-face zmdi-hc-fw"></i> USUARIOS</a>
						</li>
					</ul>
				</li>
				<?php endif ?>
			</ul>
		</div>
	</section>
	
	<!-- pageContent -->
	<section class="full-box dashboard-contentPage">
		<!-- navBar -->
		<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
			<i class="zmdi zmdi-swap btn-menu btn btn-dark text-light border btn-menu-dashboard" id="btn-menu"></i>
			<div class="container d-flex justify-content-end">
				<ul class="navbar-nav ml-auto">
					<li class="nav-item active">
						<!--div id="login">
							<a href="<?php echo $lc->encryptar($_SESSION['token']); ?>" class="btn btn-dark text-light border btn-exit-system"><i class="zmdi zmdi-power"></i>&nbsp; Salir </a>
						</div>
					</li>
				</ul-->
			</div>
		</nav>